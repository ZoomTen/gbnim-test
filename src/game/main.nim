import ../utils/interrupts
import ../utils/vram
import ../utils/print
import ../utils/itoa
import ../utils/memory
import ../utils/incdec

proc main*(): void =
  var
    i: uint16 = 0
    l: uint32 = 0
  while true:
    BgMap0.offset(10, 1).print($i)
    BgMap0.offset(10, 3).print($l & " ")
    if l == 60:
      inc i
      l = 0
    else:
      inc l
    initMalloc()
    waitInterrupt()
