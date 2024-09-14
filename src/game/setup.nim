import ../utils/vram
import ../utils/interrupts
import ../utils/memory
import ../utils/audio
import ../utils/print

import ./types
import ./gfx

import ../utils/itoa

import ../utils/sprites

import std/sugar

const spriteTemplate: seq[Sprite] = collect(newSeq):
  for y in 0 ..< 6:
    for x in 0 ..< 6:
      Sprite(y: (8 * y).uint8, x: (8 * x).uint8)

proc setup*(): void =
  ## init Game Boy hardware
  turnOffScreen()
  turnOffInterrupts()
  initMalloc()
  LcdStat[] = {}
  ScrollX[] = 0
  ScrollY[] = 0
  WinX[] = 7
  WinY[] = 0
  BgPal[] = NormalPalette
  ObjPal0[] = NormalPalette
  ObjPal1[] = NormalPalette
  AudioMasterControl[] = {}
  # clear the entirety of VRAM
  vTiles0.zeroMem(
    0x800 + 0x800 + 0x800 + # tiles
    0x400 + 0x400 # map
  )
  enableInterrupts({IntVblank})
  disableLcdcFeatures({Tiles8000})

  ## init game variables
  gsState.addr.zeroMem(sizeof(gsState))

  ## init game display
  # a cast[pointer] was done to force copying as per usual, since
  # the screen is still off.
  cast[pointer](vTiles2.offset(0x20)).copyMem(font.addr, 0x60.tiles)
  cast[pointer](vTiles0.offset(0)).copyMem(eevee.addr, (6 * 6).tiles)
  cast[pointer](vMap0.offset(3, 1)).print("Level:")
  cast[pointer](vMap0.offset(4, 3)).print("Exp:")
  cast[pointer](vMap0.offset(1, 5)).print("To next:")
  cast[pointer](vMap0.offset(2, 14)).print("POCKET CLICKER!")
  cast[pointer](vMap0.offset(3, 16)).print("Just tap A...")
  
  (Sprites.addr).copyMem(spriteTemplate[0].addr, sizeof(spriteTemplate))

  when false:
    # Copy the Eevee's sprite data
    var pSprite = Sprites[0].addr
    let pSpritesEnd =
      cast[uint16](Sprites[len(Sprites) - 1].addr) +
      uint16(sizeof(Sprites[0]))

    while cast[uint16](pSprite) != pSpritesEnd:
      pSprite[].y = 12
      pSprite = cast[typeof(pSprite)](cast[uint16](pSprite) +
        uint16(sizeof(Sprites[0])))

  enableLcdcFeatures({Win9c00, BgEnable, LcdOn})

  turnOnInterrupts()
