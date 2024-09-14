## Tools for dealing with interrupts.

type
  InterruptModes* = enum
    IntVblank = 0
    IntLcd
    IntTimer
    IntSerial
    IntJoypad

  InterruptFlags* = set[InterruptModes]

const
  InterruptEnable* = cast[ptr InterruptFlags](0xffff)
    ## `rIE`. Pointer to `InterruptFlags`_.
  InterruptFlag* = cast[ptr InterruptFlags](0xff0f)
    ## `rIF`. Pointer to `InterruptFlags`_.

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
  ##
  ## ```nim
  ## enableInterrupts({IntVblank, IntLcd})
  ## ```
  InterruptEnable[] = InterruptEnable[] + which

template disableInterrupts*(which: InterruptFlags) =
  ## Disable a set of Game Boy interrupts.
  ##
  ## ```nim
  ## disableInterrupts({IntVblank})
  ## ```
  InterruptEnable[] = InterruptEnable[] - which

template waitInterrupt*(): void =
  ## Injects a `halt` ([and a nop](https://gbdev.io/pandocs/halt.html#halt-bug)) instruction.
  asm """
    halt
    nop
  """
