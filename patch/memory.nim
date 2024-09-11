proc nimZeroMem*(p: pointer, size: Natural) =
  var
    a = cast[uint16](p)
    i = size
  while i != 0:
    cast[ptr byte](a)[] = 0'u8
    inc a
    dec i

template copyMemImpl(dest, source: pointer, size: Natural) =
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

proc nimCopyMem*(dest, source: pointer, size: Natural) =
  copyMemImpl(dest, source, size)

proc c_memcpy(dest, src: pointer, size: uint): pointer {.exportc: "__memcpy".} =
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
