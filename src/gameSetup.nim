import ./utils/vram
import ./utils/interrupts
import ./utils/memory
import ./utils/audio

proc setup*(): void =
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
  enableLcdcFeatures({Win9c00, BgEnable, LcdOn})
  turnOnInterrupts()
