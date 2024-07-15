; Miscellaneous RAM definitions.

	.module StaticRamDefs

	.area _DATA ; Static WRAM
_heap::
wHeap:: .ds 0x100 - 1
_heap_end::
wHeapEnd:: .ds 1

___data_start:: ; start of Nim-generated data variables

	.area _HRAM (ABS)
	.org 0xFF80
; The OAM DMA program for sprite updating will be
; copied here
hSpriteDMAProgram:: .ds 16

; The value of `a` upon startup.
; Functions can query this to determine GB/GBC mode.
hGBType:: .ds 1

; 01 if the system detected is GBA
; 00 otherwise
; This may be useful for determining when
; the colors should be brightened up a bit.
hIsGBA:: .ds 1

_vblankAcked:: ; Alias for referencing by C/Nim
hVBlankAcknowledged:: .ds 1

