	.module CommitSprites
	.area _OAMDMA_CODE
OAMUpdate::
; this code to be copied to HRAM on bootup
	ld a, #>_shadow_OAM
	ldh (rDMA), a
	ld a, #0x28
wait$:
	dec a
	jr nz, wait$
	ret
