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

; copy sprite committing code to HRAM
	ld de, #.

; set stack pointer
	ld sp, #STACK

; finally, jump directly to the program...
	call _NimMainModule

; program shouldn't halt, but if it does...
_exit::
1$:
	halt
	nop
	jr 1$
