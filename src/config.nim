import ./utils/config/types

when defined(nimscript): # for things that need outside access
  import os
  const
    mainFile* = "src" / "rom.nim"
    ## main source to build the ROM

# everything else

const
  romName* = "built"
  ## ROM file name, without the file extension
  ## (extension is currently .gb for now)
  romTitle* = "HELLO WORLD"
  ## Name to use inside the ROM header
  virtualSpritesStart* = 0xc000
  ## where in WRAM should the virtual OAM start
  stackStart* = 0xe000 # assuming DMG only
  ## where in WRAM should the stack grow from
  dataStart* = 0xc0a0
  ## where in WRAM should variables go
  codeStart* = 0x150
  ## where in ROM should the compiled code start
  allocType* = FreeList
  ## which allocator to use
  useGbdk* = false
  ## if we are using GBDK's libraries

  # Build script settings
  buildCacheHere* = true
  ## whether or not we should be able inspect the output here
  useNimDebuggerLines* = false
  ## enable (roughly) Nim source lines in the ASM comments
  ## may be unreliable!
