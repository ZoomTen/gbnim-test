## Sprite manipulation stuff

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

  Sprite* = object ## Sprite format required by Game Boy hardware.
    y*: uint8 ## in pixels
    x*: uint8 ## in pixels
    tile*: uint8
    flags: SpriteFlags

var Sprites* {.importc: "sprites", noinit.}: array[40, Sprite]
  ## `_sprites` should be defined in static WRAM as the location of the
  ## virtual sprite RAM. These sprites will be copied into the actual
  ## sprite memory via DMA, run every frame or so.
