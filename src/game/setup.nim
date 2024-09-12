import ../utils/vram
import ../utils/interrupts
import ../utils/memory
import ../utils/audio
import ../utils/print

import ./types
import ./gfx

import ../utils/itoa

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
  enableLcdcFeatures({Win9c00, BgEnable, LcdOn})

  ## init game variables
  gsState.addr.zeroMem(sizeof(gsState))

  ## init game display
  vTiles2.offset(0x20).copyMem(font.addr, 0x60.tiles)
  vTiles0.offset(0).copyMem(eevee.addr, (6 * 6).tiles)
  vMap0.offset(3, 1).print("Level:")
  vMap0.offset(4, 3).print("Exp:")
  vMap0.offset(1, 5).print("To next:")
  vMap0.offset(2, 14).print("POCKET CLICKER!")
  vMap0.offset(3, 16).print("Just tap A...")

  discard uitoa(1, cast[ptr cstring](0xc333), 10'u8) # 2136
  uitoaAlt(1, cast[ptr cstring](0xc333))             # 2952

  discard itoa(1, cast[ptr cstring](0xc333), 10'u8) # 2160
  itoaAlt(1, cast[ptr cstring](0xc333))             # 4028

  discard itoa(-1, cast[ptr cstring](0xc333), 10'u8) # 2256
  itoaAlt(-1, cast[ptr cstring](0xc333))             # 4132

  discard ultoa(1, cast[ptr cstring](0xc333), 10'u8) # 8576
  ultoaAlt(1, cast[ptr cstring](0xc333))             # 7876

  discard ltoa(1, cast[ptr cstring](0xc333), 10'u8) # 8656
  ltoaAlt(1, cast[ptr cstring](0xc333))             # 8980

  discard ltoa(-1, cast[ptr cstring](0xc333), 10'u8) # 8888
  ltoaAlt(-1, cast[ptr cstring](0xc333))             # 9252


  turnOnInterrupts()
