{.used.}

## Useful overrides. This could have been in utils, but it's pretty essential.
## No, apparently `import:runtime/overrides` does not work. You have to
## manually import this.

import ../macros/codegen

{.compile:"asm/vendor/itoa.asm".}
{.compile:"asm/vendor/ltoa.asm".}

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
