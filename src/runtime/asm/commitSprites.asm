	.module CommitSprites
	.include "hardware.inc"
	.area _OAMDMA_CODE

OAMUpdate::
; this code to be copied to HRAM on bootup
	ld a, #>wSpriteRAM
	ldh (rDMA), a
	ld a, #40
wait$:
	dec a
	jr nz, wait$
	ret
