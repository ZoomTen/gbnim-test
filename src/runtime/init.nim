## This file really just holds the needed ASM stuff
## needed to link together to create a working ROM.

{.used.}

# this must appear first
{.compile: "asm/sectionOrder.asm".}

# Insert hardware vectors
{.compile: "asm/hwVectors.asm".}

# Game Boy header
{.compile: "asm/header.asm".}

# ASM init
{.compile: "asm/init.asm".}

# Sprite committing code (OAM DMA update)
{.compile: "asm/commitSprites.asm".}

template initRuntimeVars*(): untyped =
  ## This should be called on initialization.

  # The Game Boy RAM is initialized to random values on bootup.
  # We can just dive in if we're using an emulator that initializes
  # everything to 0, but on more accurate emus and real HW things
  # will go bonkers, because there are a couple of global variables
  # = static allocations that Nim considers when running the program
  # and these need to be cleared out first before doing anything.
  # 
  # I should point out that NimSkull does this stuff automatically,
  # but I'd probably need to make a separate version since they do not
  # support patchFile and such other "frivolous" things... yet?

  # Clear hooks
  globalRaiseHook = nil
  localRaiseHook = nil
  outOfMemHook = nil
  unhandledExceptionHook = nil

  # Clear nimIsInErrorMode. This assumes that particular variable
  # is located directly after unhandledExceptionHook. Done this way
  # because nimIsInErrorMode can't be accessed from here.
  cast[ptr byte](cast[uint16](unhandledExceptionHook.addr) + 2)[] = 0
