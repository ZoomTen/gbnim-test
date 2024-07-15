import ../utils/memory
import ../hardware/video
import std/sugar

type StaticGameState = object
  counter: uint16
  counter2: uint8

var state: StaticGameState

proc setup*(): void =
  const
    wram = cast[ptr byte](0xc000)
    normPal = 0b11_10_01_00
  
  initMalloc()
  
  rStat[] = {}
  
  # reset scroll
  rScx[] = 0
  rScy[] = 0
  rWx[] = 7
  rWy[] = 0
  
  # reset palettes
  rBgp[] = normPal
  rObp0[] = normPal
  rObp1[] = normPal
  
  # reset sound
  cast[ptr byte](0xff26)[] = 0
  
  enableLcdcFeatures(
    {win9c00, bgEnable}
  )

## Note: safe to do heap alloc now
proc main*(): void =
  #waitFrame()
  var b = "Test"
  b.add "ABCD"
  
  vMap0.copyFrom(b[0].addr, b.len)
  
  raise newException(Defect, "lol")
  
  while true:
    asm """
      halt
      nop
    """
