import ./codegen

{.compile: "asm/vendor/itoa.asm".}
{.compile: "asm/vendor/ltoa.asm".}

const
  MaxInt16StrLen = 6
  MaxInt32StrLen = 11

proc ulToA(
    n: uint32, s: ptr cstring, radix: uint8
): cstring {.importc: "ultoa", oldCall.} =
  discard

proc lToA(
    n: int32, s: ptr cstring, radix: uint8
): cstring {.importc: "ltoa", oldCall.} =
  discard

proc uiToA(
    n: uint16, s: ptr cstring, radix: uint8
): cstring {.importc: "uitoa", oldCall.} =
  discard

proc iToA(
    n: int16, s: ptr cstring, radix: uint8
): cstring {.importc: "itoa", oldCall.} =
  discard

# TODO: turn these into templates

let powersOf10i32: array[10, int32] = [
  1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10, 1
]

let powersOf10i16: array[5, int16] = [10000, 1000, 100, 10, 1]

proc ltoaAlt*(n: int32, s: ptr cstring): void =
  var
    nn = n
    buf = cast[uint16](s)
    powp = cast[uint16](powersOf10i32[0].addr)
  let negative =
    if nn < 0:
      true
    else:
      nn = -nn
      false
  if negative:
    cast[ptr char](buf)[] = '-'
    inc buf
  var
    place_value {.noinit.}: int32
    digit {.noinit.}: byte
  let endPl = powp + (len(powersOf10i32) * sizeof(powersOf10i32[0]))
  while powp < endPl:
    place_value = cast[ptr int32](powp)[]
    digit = 0
    while nn >= place_value:
      nn -= place_value
      inc digit
    if digit != 0:
      cast[ptr byte](buf)[] = '0'.ord.byte + digit
      inc buf
    powp += sizeof(powersOf10i32[0]).uint16
  cast[ptr byte](buf)[] = 0

proc itoaAlt*(n: int16, s: ptr cstring): void =
  var
    nn = n
    buf = cast[uint16](s)
    powp = cast[uint16](powersOf10i16[0].addr)
  let negative =
    if nn < 0:
      true
    else:
      nn = -nn
      false
  if negative:
    cast[ptr char](buf)[] = '-'
    inc buf
  var
    place_value {.noinit.}: int16
    digit {.noinit.}: byte
  let endPl = powp + (len(powersOf10i16) * sizeof(powersOf10i16[0]))
  while powp < endPl:
    place_value = cast[ptr int16](powp)[]
    digit = 0
    while nn >= place_value:
      nn -= place_value
      inc digit
    if digit != 0:
      cast[ptr byte](buf)[] = '0'.ord.byte + digit
      inc buf
    powp += sizeof(powersOf10i16[0]).uint16
  cast[ptr byte](buf)[] = 0

# TODO: this works, but find a way to optimize this!
proc uitoaAlt*(n: uint16, s: ptr cstring): void =
  var buf = cast[uint16](s)
  if n == 0:
    cast[ptr byte](buf)[] = '0'.ord
    inc buf
  else:
    var
      nn = n
      powp = cast[uint16](powersOf10i16[0].addr)
    var
      place_value {.noinit.}: uint16
      digit {.noinit.}: byte
      leadingZero = true
    let endPl = powp + (len(powersOf10i16) * sizeof(powersOf10i16[0]))
    while powp < endPl:
      place_value = cast[ptr uint16](powp)[]
      digit = 0
      while nn >= place_value:
        nn -= place_value
        inc digit
      if digit != 0 and leadingZero:
        leadingZero = false
      if not leadingZero:
        cast[ptr byte](buf)[] = '0'.ord.byte + digit
        inc buf
      powp += sizeof(powersOf10i16[0]).uint16
  cast[ptr byte](buf)[] = 0

proc `$`*(x: int16): string =
  ## Nim has its own way of converting int to strings, and it does this
  ## by converting the number to int64, and performing long division
  ## on it. Modern hardware may very well handle that sort of thing,
  ## however this *will not work* on extremely limited hardware such
  ## as the Game Boy. It's an 8-bit console from 1989, after all.
  ##
  ## The default stringizing operator will throw an error complaining
  ## about `_divulonglong`, because SDCC is trying to find a division
  ## operator between two int64s, which not even GBDK provides!
  ##
  ## So, if you're having trouble with them, you should import this
  ## module and let these procs override the one from `system`.
  let strBuf: ptr cstring = cstring.create(MaxInt16StrLen)
  result = $(x.iToA(strBuf, 10.uint8))
  strBuf.dealloc()

proc `$`*(x: uint16): string =
  let strBuf: ptr cstring = cstring.create(MaxInt16StrLen)
  result = $(x.uiToA(strBuf, 10.uint8))
  strBuf.dealloc()

proc `$`*(x: int32): string =
  let strBuf: ptr cstring = cstring.create(MaxInt32StrLen)
  result = $(x.lToA(strBuf, 10.uint8))
  strBuf.dealloc()

proc `$`*(x: uint32): string =
  let strBuf: ptr cstring = cstring.create(MaxInt32StrLen)
  result = $(x.ulToA(strBuf, 10.uint8))
  strBuf.dealloc()

template `$`*(x: int8): string =
  `$`(x.int16)

template `$`*(x: uint8): string =
  `$`(x.uint16)
