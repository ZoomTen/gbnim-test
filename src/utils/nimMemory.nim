##
## This file patches `memory.nim` from the system module.
## Dunno why it's called "stdlib" when used with patchFile...
##

proc nimZeroMem*(p: pointer, size: Natural) {.compilerproc, inline.} =
  var
    a = cast[uint16](p)
    i = size
  while i != 0:
    cast[ptr byte](a)[] = 0'u8
    ## No need to override inc and dec here
    ## The compiler optimizes this as well as it would have
    inc a
    dec i

template copyMemImpl(dest, source: pointer, size: Natural) {.dirty.} =
  var
    i = cast[uint16](dest)
    j = cast[uint16](source)
    k {.noinit.}: byte
  let endAddr = i + uint16(size)
  while true:
    if i == endAddr: # don't need to check if we're over the limit
      break
    k = cast[ptr byte](j)[]
    cast[ptr byte](i)[] = k
    inc i
    inc j

proc nimCopyMem*(dest, source: pointer, size: Natural) {.compilerproc.} =
  copyMemImpl(dest, source, size)

proc c_memcpy(
    dest, src: pointer, size: uint
): pointer {.exportc: "__memcpy".} =
  ## This needs to be exposed since SDCC will automatically call this when
  ## assigning a struct. Whereas nimCopyMem doesn't need to return anything,
  ## memcpy does, and its return value will be used for the assignment.
  ##
  ## "Why are there two memcpy functions with nearly identical contents?"
  ## Well, there's your answer.
  copyMemImpl(dest, src, size)
  dest

# untested
proc nimCmpMem*(a, b: pointer, size: Natural): cint {.inline.} =
  var pa = cast[uint16](a)
  var pb = cast[uint16](b)
  var i = size
  var d {.noinit.}: byte
  while i != 0:
    d = cast[ptr byte](pa)[] - cast[ptr byte](pb)[]
    if d != 0:
      return cint(d)
    inc pa
    inc pb
    dec i

proc nimCStrLen*(s: cstring): int {.compilerproc, inline.} =
  var
    a = cast[uint16](s)
    x = cast[ptr byte](a)[]
  while x != 0:
    inc a
    x = cast[ptr byte](a)[]
    inc result
