# Joypad related stuff

{.compile: "asm/joypad.asm".}

# raw hardware constants
const
  rJoyp* = cast[ptr byte](0xff00)

# joypad result type
type
  JoypadButton* {.size: sizeof(byte).} = enum
    A = 0
    B
    Select
    Start
    Right
    Left
    Up
    Down

  JoypadButtons* = set[JoypadButton]

func getJoypad*(): JoypadButtons {.
  importc: "joypad",
  codegenDecl: "$# $#$# __preserves_regs(c,d,e,h,l)"
.}
