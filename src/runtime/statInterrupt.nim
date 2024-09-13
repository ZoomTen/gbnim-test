import ../utils/codegen

## I thought I could use this for checking hblank, but it turns out
## to be a terrible idea. It happens so often that it could spike
## CPU usage, and checking for this in the same way as Vblank would
## end up having the interrupt be virtually jumped to instantly
## every time.
##
## So for now, this is unused.

# Also referenced in ../utils/vram.nim
var statAcked {.importc, hramByte, noinit.}: bool

# Cannot use {.isr.} since it will save the contents of every register,
# which is a pretty costly operation, and this will happen way more
# often. HBlank will be over before you could even write anything :(
proc statInterrupt*(): void {.exportc: "lcd".} =
  asm "push af"
  statAcked = true
  asm """
    pop af
    reti
  """
