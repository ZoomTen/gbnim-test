; Use SDCC's malloc implementation

	.module AllocSdcc
	.area _HOME
_initMalloc::
; initialize SDCC's malloc
; point the first free block pointer
	ld hl, #(___sdcc_heap_free)
	ld a, #(___sdcc_heap)
	ld (hl+), a
	ld (hl), #(___sdcc_heap >> 8)
; initialize the first block itself
	ld hl, #(___sdcc_heap)
	ld a, #(___sdcc_heap_end)
	ld (hl+), a
	ld (hl), #(___sdcc_heap_end >> 8)
	inc hl
	xor a
	ld (hl+), a
	ld (hl), a
	ret

; shims needed for GBDK malloc
	.area _DATA
___sdcc_heap:: .ds 0x800 - 1
___sdcc_heap_end:: .ds 1

