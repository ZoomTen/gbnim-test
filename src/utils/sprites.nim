import ../config

type
  SpriteFlag* {.size: 1.} = enum
    Bank1Gfx = 0
    UseObp1
    FlipX
    FlipY
    Priority

  SpriteFlags* = object
    palette* {.bitsize: 3.}: uint8
    attributes* {.bitsize: 5.}: set[SpriteFlag]

  Sprite* = object
    y*: uint8
    x*: uint8
    tile*: uint8
    flags: SpriteFlags

var Sprites* {.importc: "sprites", noinit.}: array[40, Sprite]
