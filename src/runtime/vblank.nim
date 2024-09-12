{.used.}

import ../utils/codegen

# Also referenced in ../utils/vram.nim, since
# codegen macros don't carry over.
var vblankAcked {.importc, hramByte, noinit.}: bool

# in HRAM
proc spriteDmaProgram(): void {.importc.} = discard

proc Vblank*(): void {.exportc: "vblank", isr.} =
  spriteDmaProgram()
  vblankAcked = true
