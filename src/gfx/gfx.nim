{.compile:"gfx.asm".}

var gfx_Letters* {.importc, codegenDecl:"extern const $# $#", noinit.}: byte
var gfx_Letters_Length* {.importc, codegenDecl:"extern const $# $#", noinit.}: uint16
