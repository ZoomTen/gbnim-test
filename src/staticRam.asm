; Miscellaneous RAM definitions.

	.module StaticRamDefs

	.area _DATA ; Static WRAM
_heap::
wHeap:: .ds 0x100 - 1
_heap_end::
wHeapEnd:: .ds 1

	.area _HRAM
; The OAM DMA program for sprite updating will be
; copied here
hSpriteDMAProgram:: .ds 16

; The value of `a` upon startup.
; Functions can query this to determine GB/GBC mode.
_gbType::
hGBType:: .ds 1

; 01 if the system detected is GBA
; 00 otherwise
; This may be useful for determining when
; the colors should be brightened up a bit.
_isGba::
hIsGBA:: .ds 1

_vblankAcked:: ; Alias for referencing by C/Nim
hVBlankAcknowledged:: .ds 1

