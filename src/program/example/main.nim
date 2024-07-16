import ../../utils/[memory, waitLoop]
import ../../hardware/video
import ../../gfx/gfx
import std/sugar

type StaticGameState = object
  counter: uint16
  counter2: uint8

var state: StaticGameState

proc setup*(): void =
  initMalloc()
  rStat[] = {}
  # reset scroll
  rScx[] = 0
  rScy[] = 0
  rWx[] = 7
  rWy[] = 0
  # reset palettes
  rBgp[] = NormalPalette
  rObp0[] = NormalPalette
  rObp1[] = NormalPalette
  # reset sound
  cast[ptr byte](0xff26)[] = 0
  
  enableLcdcFeatures(
    {win9c00, bgEnable}
  )

## Note: safe to do heap alloc now
proc main*(): void =
  #waitFrame()
  vTiles0.offset(0x20).copy1bppFrom(gfx_Letters.addr, 0x30.tiles)
  
  var b = "Test"
  b.add "ABCD"
  vMap0.offset(2, 2).copyFrom(b[0].addr, b.len)
  
  let l = newException(CatchableError, "lol")
  vMap0.offset(2, 7).copyFrom(l.msg[0].addr, l.msg.len)
  while true:
    waitInterrupt()
