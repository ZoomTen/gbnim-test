; Initialization and scaffolding
; This is for stuff that MUST be done as soon as the Game Boy starts up.

	.module Init
	.include "hardware.inc"
	.area _CODE

Init::
; perform Game Boy type detection
	ldh (hGBType), a
	cp #.IS_CGB
	jr nz, dmg$

; in GBC mode, we can do an extra check if we're
; played with a GBA
	xor a
	srl e
	rla
	ldh (hIsGBA), a
dmg$:

; set stack pointer
	ld sp, #STACK

; copy sprite committing code to HRAM
	ld de, #OAMUpdate
	ld hl, #hSpriteDMAProgram
	ld c, #l__OAMDMA_CODE
	rst 0x08 ; MemcpySmall

; clear sprite RAM
	xor a
	ld hl, #wSpriteRAM
	ld c, #4 * 40
	rst 0x10 ; MemsetSmall

; finally, jump directly to the program...
	call _NimMainModule

; program shouldn't halt, but if it does...
_exit::
1$:
	halt
	nop
	jr 1$
