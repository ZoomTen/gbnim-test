; Arena based allocator
; wHeap must be defined somewhere in WRAM

	.module AllocArena
	.area _HOME
_initMalloc::
; point first free block to beginning of heap
	ld hl, #(wHeap)
	ld a, l
	ldh (hFirstFreeBlock), a
	ld a, h
	ldh (hFirstFreeBlock + 1), a
	ret

; SDCC calling convention
; de = how many bytes (assumed unsigned)
; ret:
;	bc = pointer to next
_malloc::
; first free block addr -> bc
	ldh a, (hFirstFreeBlock)
	ld c, a
	ld l, a
	ldh a, (hFirstFreeBlock + 1)
	ld b, a
	ld h, a
; update first free block addr
	add hl, de
	ld a, l
	ldh (hFirstFreeBlock), a
	ld a, h
	ldh (hFirstFreeBlock + 1), a
; bc = allocated addr
	ret

; de = which pointer
; no-op
_free::
	ret
