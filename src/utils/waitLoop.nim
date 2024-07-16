template waitInterrupt*(): void =
  ## Prevents you from coding a space heater!
  asm """
    halt
    nop
  """
