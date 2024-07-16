## 
## VRAM manipulation functions.
##

import ../utils/waitLoop

type
  rStatModes* = enum
    mode0 = 0
    mode1
    mode2
    mode3
  rStatFlag* = enum
    vBlank = 0
    busy
    coincidence
    mode00
    mode01
    mode10
    lycSelect
  rLcdcFlag* = enum
    bgEnable = 0
    objEnable
    objTall
    map9c00
    tiles8000
    winEnable
    win9c00
    lcdOn
  rStatFlags* = set[rStatFlag]
  rLcdcFlags* = set[rLcdcFlag]
  
  # `distinct` turned out a little less useful here
  # than I thought :(
  VramTileset* = distinct array[0x800, byte]
  VramTilemap* = distinct array[0x400, byte]
  VramPointer = ptr VramTileset | ptr VramTilemap

# Normally, these would be extern volatile SFR, but making them
# const makes the Nim compiler compile these as numbers to be
# dereferenced. The generated code seems to be optimized as well
# as it would if it was made volatile.
const
  rLcdc* = cast[ptr rLcdcFlags](0xff40)
  rStat* = cast[ptr rStatFlags](0xff41)
  rScy* = cast[ptr byte](0xff42)
  rScx* = cast[ptr byte](0xff43)
  rLy* = cast[ptr byte](0xff44)
  rBgp* = cast[ptr byte](0xff47)
  rObp0* = cast[ptr byte](0xff48)
  rObp1* = cast[ptr byte](0xff49)
  rWy* = cast[ptr byte](0xff4a)
  rWx* = cast[ptr byte](0xff4b)

  vTiles0* = cast[ptr VramTileset](0x8000)
  vTiles1* = cast[ptr VramTileset](0x8800)
  vTiles2* = cast[ptr VramTileset](0x9000)

  vMap0* = cast[ptr VramTilemap](0x9800)
  vMap1* = cast[ptr VramTilemap](0x9c00)
  
  NormalPalette* = 0b11_10_01_00
  ## predefined palettes
  
  InvertedPalette* = 0b00_01_10_11
  ## predefined palettes
  
  SpritePalette* = 0b10_01_00_00
  ## for sprites, first color is transparent
  ## here's some commonly-used palettes
  
# Defined in staticRam.asm, we reference it here
var vblankAcked {.
  importc: "vblankAcked",
  codegenDecl: "extern volatile __sfr /* $# */ $#",
  noinit
.}: uint8

template enableLcdcFeatures*(i: rLcdcFlags): untyped =
  ## Enable rLCDC flags.
  rLcdc[] = rLcdc[] + i

template disableLcdcFeatures*(i: rLcdcFlags): untyped =
  ## Disable rLCDC flags. If you try to disable lcdOn (`rLcdcFlag`_) using this,
  ## this will error out and you would be advised to use `turnOffScreen()`_
  ## instead.
  when lcdOn in i:
    {.error: "Please use turnOffScreen() to disable the LCD instead of specifying lcdOn".}
  rLcdc[] = rLcdc[] - i

template turnOnScreen*(): untyped =
  ## Convenience for enabling the LCD.
  enableLcdcFeatures({lcdOn})

proc turnOffScreen*(): void =
  ## Safely turns off the LCD. According to the Pan Docs, the screen
  ## cannot be turned off unless rLY hits V-blank.
  if lcdOn notin rLcdc[]:
    return
  while rLy[] <= 144:
    # Wait for Vblank first
    discard
  rLcdc[] = rLcdc[] - {lcdOn}

template tiles*(i: Natural): int =
  ## Length of 2bpp tiles in bytes.
  ##
  ## Example:
  ## ```nim
  ## 6.tiles() # 0x60 bytes
  ## ```
  i * 0x10

when false:
  ## {.borrow.} doesn't work; see nim-lang/Nim#3564
  template `[]`(a: VramTilemap, i: Ordinal): byte =
    cast[array[0x400, byte]](a)[i]
  template `[]`(a: VramTileset, i: Ordinal): byte =
    cast[array[0x800, byte]](a)[i]

  ## Expression has no address
  template offset*(base: ptr VramTilemap, x: uint, y: uint): ptr VramTilemap =
    base[][(y * 0x20) + x].addr
  
  ## Expression has no address
  template offset*(base: ptr VramTileset, tile: uint): ptr VramTileset =
    base[][tile * 0x10].addr
else: ## :(
  template offset*(base: ptr VramTilemap, x: uint, y: uint): ptr VramTilemap =
    ## Returns the memory location of some offset into the VRAM tile
    ## map address specified in `base`. All positions are relative to
    ## the top left.
    ##
    ## Example:
    ## ```nim
    ## vMap0.offset(1, 1) # 0x9821
    ## ```
    cast[ptr VramTilemap](
      cast[uint16](base) + (y * 0x20) + x
    )

  template offset*(base: ptr VramTileset, tile: uint): ptr VramTileset =
    ## Returns the memory location of some offset into the VRAM tile
    ## set address specified in `base`. The argument specifies how
    ## many tiles to offset it with.
    ##
    ## Example:
    ## ```nim
    ## vTiles1.offset(1) # 0x8810, tile #1 of tileset 0x8800
    ## ```
    cast[ptr VramTileset](
      cast[uint16](base) + (tile * 0x10)
    )

proc copyFrom*(toAddr: VramPointer, fromAddr: pointer, size: Natural) =
  ## Copy some data to VRAM even when the screen is still on.
  ## This assumes fromAddr is NOT another VRAM address!
  ##
  ## Example:
  ## ```nim
  ## let message = "Hello"
  ##
  ## # shows `message` on tile map 0x9800
  ## vMap0.offset(0, 0).copyFrom(message[0].addr, message.len)
  ## ```
  var
    val {.noinit.}: byte
    src = cast[uint16](fromAddr)
    dest = cast[uint16](toAddr)
    i = uint16(size)
  
  while i > 0:
    when false:
      while busy in rStat[]:
        discard
      ## While this would be the easy thing to do,
      ## dereferencing two pointers is costly, and the actual
      ## writing may very well be after the short window of time
      ## that VRAM is available, a classic TOCTTOU problem.
      dest[] = src[]
      dec i
    else:
      ## So instead, fetch the byte first
      val = cast[ptr byte](src)[]
      while busy in rStat[]:
        discard
      ## And then assign it as soon as VRAM is writeable.
      cast[ptr byte](dest)[] = val
      inc dest
      inc src
      dec i

proc copy1bppFrom*(toAddr: VramPointer, fromAddr: pointer, size: Natural) =
  ## A special version for copying 2-color (1bpp) tile data.
  var
    val {.noinit.}: byte
    src = cast[uint16](fromAddr)
    dest = cast[uint16](toAddr)
    i = uint16(size)
  
  while i > 0:
    val = cast[ptr byte](src)[]
    while busy in rStat[]:
      discard
    # This shouldn't take long
    cast[ptr byte](dest)[] = val
    cast[ptr byte](dest + 1)[] = val
    dest += 2'u16
    inc src
    dec i

template copyDoubleFrom*(toAddr: VramPointer, fromAddr: pointer, size: Natural) =
  ## Alias for copy1bppFrom
  copy1bppFrom(toAddr, fromAddr, size)

proc setMem*(toAddr: VramPointer, value: byte, size: Natural) =
  ## Fill VRAM locations even when the screen is still on.
  var
    destInt = cast[uint16](toAddr)
    dest {.noinit.}: ptr byte
    i = uint16(size)
  while i > 0:
    # wait for Vram
    dest = cast[ptr byte](destInt)
    while busy in rStat[]:
      discard
    # we can write to it now
    dest[] = value
    destInt += 1'u16
    i -= 1'u16

proc waitFrame*(): void =
  ## Waits for the next VBlank interrupt.
  # reset acked flag
  vblankAcked = 0
  # `== 0` or `not bool(vblankAcked)` doesn't really give me
  # some "natural" looking code
  while vblankAcked != 1:
    ## `halt` waits for ANY interrupt to fire, but only
    ## the vblank interrupt should set `vblankAcked`.
    waitInterrupt()
