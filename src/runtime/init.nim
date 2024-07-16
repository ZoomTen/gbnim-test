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
