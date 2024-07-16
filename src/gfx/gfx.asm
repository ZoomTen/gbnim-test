; because generating a whole C array of intense graphical material
; is kind of a waste tbh

	.module Graphics

	.area _HOME
_gfx_Letters::
	.incbin "src/gfx/letters.1bpp"
_gfx_Letters_Length::
	.dw . - _gfx_Letters
