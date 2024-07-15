import ./runtime/init
from program/main as program import nil

## Static RAM definitions
{.compile: "staticRam.asm".}

## Entry point
## Note: no heap allocation here
when isMainModule:
  # The Game Boy RAM is initialized to random values on bootup.
  # We can just dive in if we're using an emulator that initializes
  # everything to 0, but on more accurate emus and real HW things
  # will go bonkers, because there are a couple of global variables
  # = static allocations that Nim considers when running the program
  # and these need to be cleared out first before doing anything.
  
  # Clear hooks
  globalRaiseHook = nil
  localRaiseHook = nil
  outOfMemHook = nil
  unhandledExceptionHook = nil
  
  # Clear nimIsInErrorMode. This assumes that particular variable
  # is located directly after unhandledExceptionHook. Done this way
  # because nimIsInErrorMode can't be accessed from here.
  cast[ptr byte](cast[uint16](unhandledExceptionHook.addr) + 2)[] = 0
  
  # Alright, *now* we're ready :)
  program.setup()
  program.main()
