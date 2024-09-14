## If for some reason you want to write your V-blank routines
## in Nim, this is the place.

{.used.}

import ../utils/codegen
import ../utils/incdec

# Also referenced in ../utils/vram.nim, since
# codegen macros don't carry over.
var vblankAcked {.importc, hramByte, noinit.}: bool

# in HRAM
proc spriteDmaProgram(): void {.importc.} =
  discard

var gameCounter {.importc.}: uint16

proc Vblank*(): void {.exportc: "vblank", isr.} =
  spriteDmaProgram()
  inc gameCounter
  vblankAcked = true
