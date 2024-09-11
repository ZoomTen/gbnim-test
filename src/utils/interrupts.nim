type
  InterruptModes* = enum
    IntVblank = 0
    IntLcd
    IntTimer
    IntSerial
    IntJoypad

  InterruptFlags = set[InterruptModes]

const
  rIe* = cast[ptr InterruptFlags](0xffff)
  rIf* = cast[ptr InterruptFlags](0xff0f)

const
  InterruptEnable* = rIe
  InterruptFlag* = rIf

template turnOffInterrupts*() =
  ## Injects the `di` instruction.
  asm """
    di
  """

template turnOnInterrupts*() =
  ## Injects the `ei` instruction.
  asm """
    ei
  """

template enableInterrupts*(which: InterruptFlags) =
  ## Enable a set of Game Boy interrupts.
  rIe[] = rIe[] + which

template disableInterrupts*(which: InterruptFlags) =
  ## Disable a set of Game Boy interrupts.
  rIe[] = rIe[] - which

template waitInterrupt*(): void =
  ## Prevents you from coding a space heater!
  asm """
    halt
    nop
  """
