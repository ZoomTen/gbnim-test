import ./utils/interrupts

proc main*(): void =
  while true:
    waitInterrupt()
