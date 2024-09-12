import ./codegen

# This import definitely makes a difference :/
import ./incdec

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

# {.dirty.} is needed so that there's less risk of random identifiers
# being generated when they don't exist
# needs more work ...
template itoaGeneral[T](
    n: T,
    s: ptr cstring,
    tableToUse: untyped,
    accountForNegative: static bool,
): void {.dirty.} =
  var bufferCursor = cast[uint16](s)
  if n == 0:
    cast[ptr byte](bufferCursor)[] = '0'.ord
    inc bufferCursor
  else:
    var nMutable = n
    # append '-' character to beginning of string
    when accountForNegative:
      if (
        if nMutable < 0:
          true
        else:
          # Could be replaced with toggling the high bit?
          nMutable = -nMutable
          false
      ):
        cast[ptr char](bufferCursor)[] = '-'
        inc bufferCursor
    # do print
    var
      pow10Cursor = cast[uint16](tableToUse[0].addr)
      placeValue {.noinit.}: typeof(n)
      asciiDigit: byte = '0'.ord.byte
      leadingZero = true
    let pow10End = cast[uint16](tableToUse[len(tableToUse) - 1].addr)
    while pow10Cursor < pow10End:
      placeValue = cast[ptr typeof(n)](pow10Cursor)[]
      while nMutable >= placeValue:
        nMutable -= placeValue
        inc asciiDigit
      if asciiDigit != '0'.ord.byte and leadingZero:
        leadingZero = false
      if not leadingZero:
        cast[ptr byte](bufferCursor)[] = asciiDigit
        inc bufferCursor
      pow10Cursor += uint16(sizeof(powersOf10i16[0]))
  cast[ptr byte](bufferCursor)[] = 0

proc ltoaAlt*(n: int32, s: ptr cstring): void =
  itoaGeneral(n, s, powersOf10i32, true)

proc ultoaAlt*(n: uint32, s: ptr cstring): void =
  itoaGeneral(n, s, powersOf10i32, false)

proc itoaAlt*(n: int16, s: ptr cstring): void =
  itoaGeneral(n, s, powersOf10i16, true)

proc uitoaAlt*(n: uint16, s: ptr cstring): void =
  itoaGeneral(n, s, powersOf10i16, false)

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
