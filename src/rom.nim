import ./runtime/init
from program/main as program import nil

## Static RAM definitions
{.compile: "staticRam.asm".}

## Entry point
## Note: no heap allocation here
when isMainModule:
  program.setup()
  program.main()
