## Program's entry point from the Nim side.

import ./runtime/init
from ./gameSetup import setup
from ./gameMainLoop import main

# Static RAM definitions
{.compile: "staticRam.asm".}

# Entry point. Note: no heap allocation here!
when isMainModule:
  # This must be present, otherwise nimIsInErrorMode
  # will be set to random garbage, which can throw our
  # program early.
  initRuntimeVars()

  # Alright, *now* we're ready :)
  setup()
  main()
