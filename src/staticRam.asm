; Miscellaneous RAM definitions.

	.module StaticRamDefs

;;;;;;;; WRAM ;;;;;;;;
	.area _DATA

_heap::
wHeap:: .ds 0x100 - 1
_heap_end::
wHeapEnd:: .ds 1

;;;;;;;; end WRAM ;;;;;;;;

	.area _SPRITES
; Needs to be on a boundary of 0x100
; because the value to be loaded into the rDMA
; register is HIGH(wSpriteRAM).
; 4 bytes per sprite * 40 sprites
wSpriteRAM:: .ds 4 * 40

;;;;;;;; HRAM ;;;;;;;;
	.area _HRAM
; The OAM DMA program for sprite updating will be
; copied here
_spriteDmaProgram::
hSpriteDMAProgram:: .ds 0xA ; sizeof(_OAMDMA_CODE)

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

; Will be set to 01 by the VBlank routine.
_vblankAcked:: ; Alias for referencing by C/Nim
hVBlankAcknowledged:: .ds 1

;;;;;;;; end HRAM ;;;;;;;;

