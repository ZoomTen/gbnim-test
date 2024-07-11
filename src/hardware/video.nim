## 
## VRAM manipulation functions.
##

{.compile: "asm/video.asm".}

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

  vTiles0* = cast[ptr array[0x800, byte]](0x8000)
  vTiles1* = cast[ptr array[0x800, byte]](0x8800)
  vTiles2* = cast[ptr array[0x800, byte]](0x9000)

  vMap0* = cast[ptr array[0x400, byte]](0x9800)
  vMap1* = cast[ptr array[0x400, byte]](0x9c00)

## Enable rLCDC flags
template enableLcdcFeatures*(i: rLcdcFlags): untyped =
  rLcdc[] = rLcdc[] + i

## Disable rLCDC flags
template disableLcdcFeatures*(i: rLcdcFlags): untyped =
  when lcdOn in i:
    {.error: "Please use turnOffScreen() to disable the LCD instead of specifying lcdOn".}
  rLcdc[] = rLcdc[] - i

template turnOnScreen*(): untyped =
  enableLcdcFeatures({lcdOn})

func turnOffScreen*(): void =
  if lcdOn notin rLcdc[]:
    return
  while rLy[] <= 144:
    discard
  rLcdc[] = rLcdc[] - {lcdOn}

## Length of 2bpp tiles in bytes; example: 6.tiles(); or just 6.tiles
template tiles*(i: Natural): int =
  i * 0x10

## Fill VRAM locations even when the screen is still on.
func setVram*(toAddr: pointer, value: byte, size: Natural) =
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

## Copy some data to VRAM even when the screen is still on.
## This assumes fromAddr is NOT another VRAM address!
func copyVramFrom*(toAddr, fromAddr: pointer, size: Natural) =
  var
    val {.noinit.}: byte
    src = cast[uint16](fromAddr)
    dest = cast[uint16](toAddr)
    i = uint16(size)
  
  while i > 0:
    when false:
      while busy in rStat[]: discard
      ## While this would be the easy thing to do,
      ## dereferencing two pointers is costly, and the actual
      ## writing may very well be after the short window of time
      ## that VRAM is available, a classic TOCTTOU problem.
      dest[] = src[]
    else:
      ## So instead, fetch the byte first
      val = cast[ptr byte](src)[]
      while busy in rStat[]:
        discard
      ## And then assign it as soon as VRAM is writeable.
      cast[ptr byte](dest)[] = val
    dest += 1'u16
    src += 1'u16
    i -= 1'u16

## Defined in asm, since this accesses HRAM. I don't know how to tell
## SDCC that my extern variable's in HRAM and not WRAM so it can
## optimize it down to an ldh.
## The other way is to write a constant here, it can automatically tell
## that it's in HRAM.
proc waitFrame*(): void {.
  importc:"waitFrame",
  codegenDecl: "$# $#$# __preserves_regs(b,c,d,e,h,l)"
.} = discard
