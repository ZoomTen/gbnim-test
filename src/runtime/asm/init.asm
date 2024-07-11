; Initialization and scaffolding

	.include "include/hardware.inc"
	.area _CODE

Init::
	di

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

; clear some part of the stack (for debugging)
	ld hl, #(STACK-0x800)
	ld bc, #0x800
	xor a
1$:
	ld (hl+), a
	dec c
	jr nz, 1$
	dec b
	jr nz, 1$

; set stack pointer
	ld sp, #STACK

; ; initialize SDCC's malloc
; ; point the first free block pointer
; 	ld hl, #(___sdcc_heap_free)
; 	ld a, #(___sdcc_heap)
; 	ld (hl+), a
; 	ld (hl), #(___sdcc_heap >> 8)
; ; initialize the first block itself
; 	ld hl, #(___sdcc_heap)
; 	ld a, #(___sdcc_heap_end)
; 	ld (hl+), a
; 	ld (hl), #(___sdcc_heap_end >> 8)
; 	inc hl
; 	xor a
; 	ld (hl+), a
; 	ld (hl), a

; ___data_start should be where the global variables are
; defined just after the heap stuff in mallocShims.asm
; we have to initialize this since Nim sets a variable here
; for exceptions and the like ("in error mode")
	ld hl, #___data_start
	ld c, #0xff
2$:
	ld (hl+), a
	dec c
	jr nz, 2$

; finally, jump directly to the program...
	call _NimMainModule

; program shouldn't halt, but if it does...
_exit::
1$:
	halt
	nop
	jr 1$
