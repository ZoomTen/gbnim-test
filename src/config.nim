## -----------------
## ROM configuration
## -----------------
## 
## Some constants here are used by the `tools/` compiler front-end.
## Should you change any of these, you will need to do a rebuild of
## these tools, which you can do by:
## 
## ```cmd
## nim cleanDist
## nim build
## ```

import ./utils/config/types

# Constants used by config.nims

when defined(nimscript) or defined(nimsuggest) or defined(nimdoc):
  # for things that need outside access
  import os
  const mainFile* = "src" / "rom.nim" ## main source to build the ROM

const
  romName* = "built"
    ## ROM file name, without the file extension
    ## (extension is currently .gb for now)
  buildCacheHere* = true
    ## whether or not we should be able inspect the output here
  useNimDebuggerLines* = false
    ## enable (roughly) Nim source lines in the ASM. comments
    ## may be unreliable!

# Constants used by the program

const
  allocType*: AllocType = FreeList ## which allocator to use
  useVendorItoa* = false
    ## if we should use vendored GPL'd itoa or my crappy version
    ## which is a lot slower.

# Constants used by the tooling

const
  romTitle* = "HELLO WORLD"
    ## Name to use inside the ROM header
    ## 
    ## .. note:: requires tool rebuild.
  virtualSpritesStart* = 0xc000
    ## where in WRAM should the virtual OAM start
    ## 
    ## .. note:: requires tool rebuild.
  stackStart* = 0xe000
    ## where in WRAM should the stack grow from
    ## 
    ## .. note:: requires tool rebuild.
  dataStart* = 0xc0a0
    ## where in WRAM should variables go
    ## 
    ## .. note:: requires tool rebuild.
  codeStart* = 0x150
    ## where in ROM should the compiled code start
    ## 
    ## .. note:: requires tool rebuild.
  useGbdk* = false
    ## if we are using GBDK's libraries
    ## 
    ## .. note:: requires tool rebuild.
  compilerMaxAlloc* = 50_000
    ## controls SDCC's --max-alloc-per-node setting.
    ## higher value = better code gen but longer to compile.
    ## 
    ## .. note:: requires tool rebuild.
