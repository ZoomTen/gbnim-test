import ../utils/codegen

{.compile: "gfx.asm".}

var font* {.importc, asmDefined, noinit.}: uint8
var eevee* {.importc, asmDefined, noinit.}: uint8
