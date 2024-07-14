; Use SDCC's malloc implementation

_initSdccMalloc::
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

