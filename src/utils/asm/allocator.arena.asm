; Arena/stack based allocator

	.area _HOME
_myMallocInit::
; point first free block to beginning of heap
	ld hl, #(wMyHeap)
	ld a, l
	ldh (hFirstFreeBlock), a
	ld a, h
	ldh (hFirstFreeBlock + 1), a
	xor a
	ldh (hLastAllocationSize), a
	ldh (hLastAllocationSize + 1), a
	ldh (hLastAllocatedBlock), a
	ldh (hLastAllocatedBlock + 1), a
	ret

; SDCC calling convention
; de = how many bytes (assumed unsigned)
; ret:
;	bc = pointer to next
_myMalloc::
; update last allocation size
	ld a, e
	ldh (hLastAllocationSize), a
	ld a, d
	ldh (hLastAllocationSize + 1), a
; first free block addr -> hl, bc
; and also update last allocated block addr
	ldh a, (hFirstFreeBlock)
	ldh (hLastAllocatedBlock), a
	ld c, a
	ld l, a
	ldh a, (hFirstFreeBlock + 1)
	ldh (hLastAllocatedBlock + 1), a
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
_myFree::
; The freed pointer MUST be the last allocation done
; before this point, otherwise, it is a no-op
	ldh a, (hLastAllocatedBlock + 1)
	cp d
	ret nz
	ldh a, (hLastAllocatedBlock)
	cp e
	ret nz
; first free block -> hl
	ldh a, (hFirstFreeBlock)
	ld l, a
	ldh a, (hFirstFreeBlock + 1)
	ld h, a
; last allocation size -> bc
	ldh a, (hLastAllocationSize)
	ld c, a
	ldh a, (hLastAllocationSize + 1)
	ld b, a
; first free block -= last allocation size
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
; update first free block addr
	ldh (hFirstFreeBlock + 1), a
	ld a, l
	ldh (hFirstFreeBlock), a
	ret
