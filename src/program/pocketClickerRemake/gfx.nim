import ../../macros/codegen

{.compile:"gfx.asm".}

var font* {.importc, asmDefined, noinit.}: uint8
