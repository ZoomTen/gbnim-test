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
  
  # clear RAM
  # idc that I "shouldn't do it"
  wram.clearMem(0xdff0-0xc000)
  
  initArenaMalloc()
  
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
  waitFrame()
  turnOffScreen()
  
  cast[ptr byte](14).copyFrom(
    cast[ptr byte](0),
    194
  )
  vMap0.copyFrom(
    cast[ptr byte](0),
    194
  )
  when false:
    let j = cast[ptr array[0x30,byte]](myAlloc(0x30))
    for aa in 0..<len(j[]):
      j[aa] = 194'u8
    
    let m = myCalloc(0x10)
    let something = "Abcdef"
    rBgp[] = cast[byte](something[0])
  var b = "Test"
  b.add "ABCD"
  for i in 0..<b.len:
    rBgp[] = uint8(b[i])
  raise newException(Defect, "aaa")
