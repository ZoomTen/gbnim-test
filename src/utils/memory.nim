## 
## Memory manipulation functions.
##

## C assumes memset returns a ptr byte, but we're not doing that
## here to reduce stack allocations. If you want that, you'll have
## to calculate the end address manually beforehand.
##
## Also, Nim does not seem to make nimSetMem available, so we'll
## have to make do anyway.
proc setMemImpl(start: pointer, value: byte, length: Natural): void {.inline.} =
  when false:
    ## Idiomatically (I think), this would have been done like this:
    let
      s = cast[uint16](start)
      e = s + uint16(length)
    for i in s..e:
      cast[ptr byte](i)[] = value
    ## ...but this generates way too much code for my liking.
  else:
    ## So, this approach was used instead:
    var i = cast[uint16](start)
    while i < cast[uint16](start) + uint16(length):
      cast[ptr byte](i)[] = value
      i += 1'u16
    ## Nim does not compile a for loop into C for loops, which
    ## SDCC at least recognizes...

## This variant should be automatically called when you invoke setMem
## with a constant value, it just tells you to use zeroMem (from system)
## if you use it with a value == 0x00.
template setMem*(start: pointer, value: static byte, length: Natural) =
  when value == 0x00:
    {.warning: "setMem called with 0x00, better to use zeroMem instead".}
  setMemImpl(start, value, length)

template setMem*(start: pointer, value: byte, length: Natural) =
  setMemImpl(start, value, length)

## Generic memory copying routine. copyMem is exposed in the system
## module, however that one does dereferencing in a loop, which on
## the Game Boy is pretty expensive.
##
## Until I find out a way to override system procs, please use this
## instead.
proc copyFrom*(to, src: pointer, length: Natural): void {.discardable.} =
  var
    i = cast[uint16](to)
    j = cast[uint16](src)
  while i < uint16(length):
    cast[ptr byte](i)[] = cast[ptr byte](j)[]
    i += 1'u16
    j += 1'u16

############## myMalloc ################################################

const useArena = false

when useArena:
  {.compile:"asm/allocator.arena.asm".}
else:
  {.compile:"asm/allocator.freeList.asm".}

## This can also be used to free all allocations instantly
proc initMyMalloc*(): void {.importc:"myMallocInit".}

proc myMalloc*(size: uint16): pointer {.importc:"myMalloc".}

when false:
  proc myFree*(which: pointer): void {.importc:"myFree".}
else:
  var firstFree {.
    importc: "first_free",
    codegenDecl: "extern volatile __sfr /* $# */ $#",
    noinit
  .}: uint16
  proc myFree*(which: pointer): void  {.exportc:"myFree".}=
    asm """
     jp _myFree2
    """
    if cast[uint16](which) == 0:
      return

    type
      MemBlock = object
        nextBlock: ptr MemBlock
        nextFree: ptr MemBlock
    var
      prevFree = cast[ptr MemBlock](0)
      thisBlockPtr = cast[ptr ptr MemBlock](firstFree.addr)
      thisBlock = cast[ptr MemBlock](thisBlockPtr[])
    while (thisBlock != nil) and (cast[uint16](thisBlock) < cast[uint16](which)):
      prevFree = thisBlock
      thisBlockPtr = thisBlock.nextFree.addr
      thisBlock = thisBlock.nextFree
    var
      nextFree = thisBlock
    thisBlock = cast[ptr MemBlock](cast[uint16](which) - 2)
    thisBlock.nextFree = nextFree
    thisBlockPtr[] = thisBlock
    if nextFree == thisBlock.nextBlock:
      ## merge with next block
      thisBlock.nextFree = thisBlock.nextBlock.nextFree
      thisBlock.nextBlock = thisBlock.nextBlock.nextBlock
    if (prevFree != nil) and (prevFree.nextBlock == thisBlock):
      ## merge with previous block
      prevFree.nextBlock = thisBlock.nextBlock
      prevFree.nextFree = thisBlock.nextFree
    
proc myCalloc*(size: uint16): pointer {.exportc:"myCalloc".} =
  var
    counter = size
    current = cast[uint16](myMalloc(size))
    start = current
  while counter > 0:
    cast[ptr byte](current)[] = 7
    current += 1
    counter -= 1
  return cast[ptr byte](start)

############## sdccMalloc ##############################################

proc initSdccMalloc*(): void {.importc:"initSdccMalloc".}

