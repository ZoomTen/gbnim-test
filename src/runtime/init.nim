# This file really just holds the needed ASM stuff
# needed to link together
{.used.}

# this must appear first
{.compile: "asm/sectionOrder.asm".}

# Definitions needed for SDCC malloc
{.compile: "asm/mallocShims.asm".}

# Insert hardware vectors
{.compile: "asm/hwVectors.asm".}

# Game Boy header
{.compile: "asm/header.asm".}

# ASM init
{.compile: "asm/init.asm".}
