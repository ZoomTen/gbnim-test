; Miscellaneous RAM definitions.
	.area _DATA ; Static WRAM
wMyHeap:: .ds 0x100
wMyHeapEnd:: .ds 1

___data_start:: ; start of Nim-generated data variables

	.area _HRAM (ABS)
.org 0xff80
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

_first_free:: ; Alias for referencing by C/Nim
hFirstFreeBlock:: .ds 2 ; for arena and free-list alloc

hLastAllocatedBlock:: .ds 2 ; for arena alloc
hLastAllocationSize:: .ds 2 ; for arena alloc
