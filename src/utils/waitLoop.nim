## Prevents you from coding a space heater!
template waitInterrupt*(): void =
  asm """
    halt
    nop
  """
