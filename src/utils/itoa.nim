## `itoa` integer to string conversion utilities.
## 
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
## module and let the `$` procs from here override the one from `system`.

import ./codegen

import ../config

const
  MaxInt16StrLen = 6
  MaxInt32StrLen = 11

when useVendorItoa:
  ## Vendored itoa
  {.compile: "asm/vendor/itoa.asm".}
  {.compile: "asm/vendor/ltoa.asm".}
  proc ultoa*(
      n: uint32, s: ptr cstring, radix: uint8
  ): cstring {.importc, oldCall.} =
    discard

  proc ltoa*(
      n: int32, s: ptr cstring, radix: uint8
  ): cstring {.importc, oldCall.} =
    discard

  proc uitoa*(
      n: uint16, s: ptr cstring, radix: uint8
  ): cstring {.importc, oldCall.} =
    discard

  proc itoa*(
      n: int16, s: ptr cstring, radix: uint8
  ): cstring {.importc, oldCall.} =
    discard

else: # My itoa
  # This import definitely makes a difference :/
  import ./incdec

  let powersOf10i32: array[10, int32] = [
    1000000000, 100000000, 10000000, 1000000, 100000, 10000, 1000, 100, 10,
    1,
  ]
  let powersOf10i16: array[5, int16] = [10000, 1000, 100, 10, 1]

  # Let some stuff spill onto global memory :)
  # Even the stack is expensive...
  var
    bufferCursor {.noinit, exportc.}: uint16
    pow10Cursor {.noinit, exportc.}: uint16
    asciiDigit {.noinit, exportc.}: byte
    itoaCounter {.noinit, exportc.}: uint8
    leadingZero {.noinit, exportc.}: bool
    ## this is ridiculous...

  # {.dirty.} is needed so that there's less risk of random identifiers
  # being generated when they don't exist
  # needs more work ...algo is kinda shit anyway it's O(something n)
  template itoaGeneral(
      n: SomeInteger,
      s: ptr cstring,
      tableToUse: untyped,
      accountForNegative: static bool,
  ): void {.dirty.} =
    bufferCursor = cast[uint16](s)
    if n == 0:
      cast[ptr byte](bufferCursor)[] = '0'.ord
      inc bufferCursor
    else:
      var nMutable = n
      when accountForNegative:
        # append '-' character to beginning of string
        if (
          if nMutable < 0:
            # Could be replaced with toggling the high bit?
            nMutable = -nMutable
            true
          else:
            false
        ):
          cast[ptr char](bufferCursor)[] = '-'
          inc bufferCursor
      # do print
      var placeValue {.noinit.}: typeof(n)
      pow10Cursor = cast[uint16](tableToUse[0].addr)
      itoaCounter = 0
      leadingZero = true
      while itoaCounter < len(tableToUse).uint8:
        placeValue = cast[ptr typeof(n)](pow10Cursor)[]
        asciiDigit = '0'.ord.byte
        while nMutable >= placeValue:
          nMutable -= placeValue
          inc asciiDigit
        if asciiDigit != '0'.ord.byte and leadingZero:
          leadingZero = false
        if not leadingZero:
          cast[ptr byte](bufferCursor)[] = asciiDigit
          inc bufferCursor
        pow10Cursor += uint16(sizeof(tableToUse[0]))
        inc itoaCounter
    cast[ptr byte](bufferCursor)[] = 0

  proc ltoa*(n: int32, s: ptr cstring): void =
    itoaGeneral(n, s, powersOf10i32, true)

  proc ultoa*(n: uint32, s: ptr cstring): void =
    itoaGeneral(n, s, powersOf10i32, false)

  proc itoa*(n: int16, s: ptr cstring): void =
    itoaGeneral(n, s, powersOf10i16, true)

  proc uitoa*(n: uint16, s: ptr cstring): void =
    itoaGeneral(n, s, powersOf10i16, false)

proc `$`*(x: int16): string =
  let strbuf: ptr cstring = cstring.create(MaxInt16StrLen)
  result =
    when useVendorItoa:
      $(x.itoa(strbuf, 10.uint8))
    else:
      x.itoa(strbuf)
      $cast[cstring](strbuf)
  strbuf.dealloc()

proc `$`*(x: uint16): string =
  let strbuf: ptr cstring = cstring.create(MaxInt16StrLen)
  result =
    when useVendorItoa:
      $(x.uitoa(strbuf, 10.uint8))
    else:
      x.uitoa(strbuf)
      $cast[cstring](strbuf)
  strbuf.dealloc()

proc `$`*(x: int32): string =
  let strbuf: ptr cstring = cstring.create(MaxInt32StrLen)
  result =
    when useVendorItoa:
      $(x.ltoa(strbuf, 10.uint8))
    else:
      x.ltoa(strbuf)
      $cast[cstring](strbuf)
  strbuf.dealloc()

proc `$`*(x: uint32): string =
  let strbuf: ptr cstring = cstring.create(MaxInt32StrLen)
  result =
    when useVendorItoa:
      $(x.ultoa(strbuf, 10.uint8))
    else:
      x.ultoa(strbuf)
      $cast[cstring](strbuf)
  strbuf.dealloc()

template `$`*(x: int8): string =
  `$`(x.int16)

template `$`*(x: uint8): string =
  `$`(x.uint16)
