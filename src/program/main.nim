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
  
  asm """
  call myMallocInit
  """
  
  let j = cast[ptr array[0x30,byte]](myAlloc(0x30))
  for aa in 0..<len(j[]):
    j[aa] = 194'u8
  
  let m = myCalloc(0x10)
  
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

proc main*(): void =
  clearMem(
    cast[ptr byte](0xc000),
    0x1000
  )
  setMem(
    cast[ptr byte](0xc000),
    0x00,
    0x500
  )
  var i = 0'u8
  for k in 0'u8..5'u8:
    i += 9'u8
  setMem(
    cast[ptr byte](0xcd00),
    i,
    0x250
  )
  
  cast[ptr byte](0xce00)
    .copyFrom(
      cast[ptr byte](0xc000),
      104
    )
  
  let
    test = "ABCDEF"
    ij = 0
  
  enableLcdcFeatures {bgEnable}
  #vMap0.setVram(test[ij], 105)
  vMap0.copyVramFrom(test[0].addr, test.len)
  waitFrame()
  
  state.counter += 1
