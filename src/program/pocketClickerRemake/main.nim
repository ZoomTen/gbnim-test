import ../../utils/[memory]
import ../../hardware/[video, audio, interrupts]
import ./[init, update]

proc setup*(): void =
  turnOffScreen()
  turnOffInterrupts()
  
  initMalloc()
  
  # clear
  GbLcdStat[] = {}
  
  # reset scroll
  GbScrollX[] = 0
  GbScrollY[] = 0
  GbWinX[] = 7
  GbWinY[] = 0
  
  # reset palettes
  GbBgPal[] = NormalPalette
  GbObjPal0[] = NormalPalette
  GbObjPal1[] = NormalPalette
  
  # reset sound
  GbAudioMasterControl[] = {}
  
  # clear the entirety of VRAM
  vTiles0.zeroMem(
    0x800 + 0x800 + 0x800 + # tiles
    0x400 + 0x400 # map
  )
  enableInterrupts({
    IntVblank
  })
  enableLcdcFeatures({
    Win9c00,
    BgEnable,
    LcdOn
  })
  gameInit()
  turnOnInterrupts()

proc main*(): void =
  while true:
    gameUpdate()
    waitInterrupt()
    
