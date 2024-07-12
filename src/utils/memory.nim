## 
## Memory manipulation functions.
##

{.compile:"asm/memory.asm".}

template setMemImpl(start: pointer, value: byte, length: Natural) {.dirty.} =
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

## setMem and clearMem should return ptr byte, but actually making that
## its return type creates stack allocations in the resulting ASM code.
##
## Setting them to return a uint16 avoids that, so if you want to use
## its return value, you should cast[ptr byte].
proc setMem(start: pointer, value: byte, length: Natural): uint16 {.discardable.} =
  setMemImpl(start, value, length)
  return i

## A separate proc was needed for optimization, for one this requires
## only two arguments, avoiding stack allocation. And since the value
## is fixed (and known to be 0), SDCC can recognize and optimize that.
proc clearMem*(start: pointer, length: Natural): uint16  {.discardable.} =
  setMemImpl(start, 0, length)
  return i

## This variant should be automatically called when you invoke setMem
## with a constant value, it just tells you to use clearMem if you
## use it with a value == 0x00.
template setMem*(start: pointer, value: static byte, length: Natural) =
  when value == 0x00:
    {.warning: "setMem called with 0x00, it's better to use clearMem instead".}
  setMem(start, value, length)

template setMem*(start: pointer, value: byte, length: Natural) =
  setMem(start, value, length)

## Generic memory copying routine.
proc copyFrom*(to, src: pointer, length: Natural): uint16 {.discardable.} =
  var
    i = cast[uint16](to)
    j = cast[uint16](src)
  while i < uint16(length):
    cast[ptr byte](i)[] = cast[ptr byte](j)[]
    i += 1'u16
    j += 1'u16
  return i

############## myMalloc ################################################

proc initMyMalloc*(): void {.importc:"myMallocInit".}
proc myAlloc*(size: uint16): pointer {.importc:"myMalloc".}

proc myCalloc*(size: uint16): pointer {.exportc:"myCalloc".} =
  var
    counter = size
    current = cast[uint16](myAlloc(size))
    start = current
  while counter > 0:
    cast[ptr byte](current)[] = 7
    current += 1
    counter -= 1
  return cast[ptr byte](start)

proc myAllocFree*(which: pointer): void {.exportc:"myFree".} =
  ## TODO
  return

############## sdccMalloc ##############################################

proc initSdccMalloc*(): void {.importc:"initSdccMalloc".}

############## arenaMalloc #############################################

proc initArenaMalloc*(): void {.importc:"arenaInit".}
proc arenaFreeAll*(): void {.importc:"arenaFreeAll".}
proc arenaAlloc*(size: uint16): pointer {.importc:"arenaAlloc".}
proc arenaFree*(): void {.importc:"arenaFree".}
proc arenaCalloc*(size: uint16): pointer {.exportc:"arenaCalloc".} =
  var
    counter = size
    current = cast[uint16](arenaAlloc(size))
    start = current
  while counter > 0:
    cast[ptr byte](current)[] = 7
    current += 1
    counter -= 1
  return cast[ptr byte](start)
