; structure of block:
; 	<pointer to next block or end of heap>
; 	<block's data or some pointer idk>

	.area _HOME
_myMallocInit::
	; point first free block to beginning of heap
	ld hl, #(wMyHeap)
	ld a, l
	ldh (hFirstFreeBlock), a
	ld a, h
	ldh (hFirstFreeBlock + 1), a
	; for the first block initially, point the "next block"
	; to end of heap
	ld (hl), #(wMyHeapEnd)
	inc hl
	ld (hl), #(wMyHeapEnd >> 8)
	inc hl
	xor a
	; and for its "next free block" pointer have a zero to
	; mark no more free blocks left (because so far this is the only one)
	ld (hl+), a
	ld (hl), a
	ret

_arenaFreeAll::
_arenaInit::
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

; SDCC calling convention
; de = how many bytes (assumed unsigned)
; ret:
;	bc = pointer to next
_arenaAlloc::
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
_arenaFree::
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

; SDCC calling convention
; de = how many bytes (assumed unsigned)
; ret:
;	bc = 0 or pointer to next
_myMalloc::
; de == 0?
	ld a, d
	cp e
	ld bc, #0
	ret z
; add size of header (2)
; the 2 other bytes for "next free" can overlap
; so we don't account for it here
	inc de
	inc de
; ...but here, we do though
; so the adjusted size must be >= 4
	ld a, d
	and a
	jr nz, no_adjust$
	ld a, e
	cp #4
	jr nc, no_adjust$
	ld de, #0x0004
no_adjust$:
; find size of this block
; first free block's loc -> bc
	ldh a, (hFirstFreeBlock)
	ld c, a
	ldh a, (hFirstFreeBlock + 1)
	ld b, a
; next block's loc -> hl
	ld a, (bc)
	ld l, a
	inc bc
	ld a, (bc)
	ld h, a
; hl - bc
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
; if hl <= de then bc == 0
	ld a, h
	cp d
	jr c, after_compare$
	jr nz, after_compare$
	ld a, l
	cp e
after_compare$:
	jr c, oom$
; we've got enough memory, reserve the next block
; push the current next block ptr forwards
	ld a, (bc)
	ld h, a
	dec bc
	ld a, (bc)
	ld l, a
	push hl
		ld h, b
		ld l, c
		add hl, de
	pop de
	ld (hl), e
	inc hl
	ld (hl), d
	dec hl
; put the address of the next block ptr at this block
; and update the first free block ptr
	ld a, l
	ld (bc), a
	ldh (hFirstFreeBlock), a
	inc bc
	ld a, h
	ld (bc), a
	ldh (hFirstFreeBlock + 1), a
	inc bc
; bc = the allocated data pointer
; we're done
	ret
oom$:
	ld bc, #0
	ret

_myFree:: ; TODO
	ret
