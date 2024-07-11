	.area _HOME

_waitFrame::
	xor a
	ldh (hVBlankAcknowledged), a
0$:
	halt
	nop
	ldh a, (hVBlankAcknowledged)
	ret nz
	jr 0$
