; Implicit free-list based allocator
; Inspired by SDCC's implementation

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

; SDCC calling convention
; de = how many bytes (assumed unsigned)
; ret:
;	bc = 0 or pointer to next
_myMalloc::
; de == 0?
	ld a, d
	or e
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
; push the current next block ptr AND next free block ptr forwards
	inc bc
	inc bc
	ld l, c
	ld h, b
	add hl, de
	.rept 3
		ld a, (bc)
		ld (hl-), a
		dec bc
	.endm
	ld a, (bc)
	ld (hl), a
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

; de = which pointer to free?
; ret:
;	nothing
_myFree2:: ; TODO
; do nothing if pointer == NULL
	ld a, d
	or e
	ret z
; (ptr)prevFree = 0
	ld hl, #wPrevFree
	xor a
	ld (hl+), a
	ld (hl+), a
; wThisBlockPtr = hFirstFreeBlock
	ld (hl), #(hFirstFreeBlock)
	inc hl
	ld (hl), #(hFirstFreeBlock >> 8)
	inc hl
; thisBlock -> bc
	ld a, (hFirstFreeBlock)
	ld c, a
	ld a, (hFirstFreeBlock + 1)
	ld b, a
continue_iter$:
; thisBlock = nil? skip iter
	or c
	jr z, skip_iter$
; thisBlock >= which? skip_iter
	ld a, c
	sub e
	ld a, b
	sbc d
	jr nc, skip_iter$
; wPrevFree = thisBlock
	ld hl, #wPrevFree
	ld a, c
	ld (hl+), a
	ld a, b
	ld (hl+), a
	inc bc
	inc bc ; bc = thisBlock.nextFree
; TODO
; thisBlockPtr = thisBlock nextFree addr
	ld (hl), c
	inc hl
	ld (hl), b
; thisBlock = thisBlock nextFree
	ld l, c
	ld b, h
	ld a, (hl+)
	ld c, a
	ld a, (hl)
	jr continue_iter$
skip_iter$:
; thisBlock -> bc
; nextFree = thisBlock
	ld hl, #wNextFree
	ld (hl), c
	inc hl
	ld (hl), b
; thisBlock.nextFree = nextFree
	inc de
	ld a, b
	ld (de), a
	dec de
	ld a, c
	ld (de), a
	dec de
	dec de
; thisblockptr = thisblock
	ld a, (wThisBlockPtr)
	ld l, a
	ld a, (wThisBlockPtr + 1)
	ld h, a
	ld (hl), c
	inc hl
	ld (hl), b
; if nextFree == thisBlock.nextBlock:
	inc bc
	inc bc
	ld a, (wNextFree)
	cp c
	jr nz, check_should_merge_prev$
	ld a, (wNextFree + 1)
	cp b
	jr nz, check_should_merge_prev$
; merge with next block
; thisBlock.nextFree @bc = thisBlock.nextBlock.nextFree
	; thisBlock -> hl
	ld a, c
	sub 2
	ld l, a
	ld a, b
	sbc 0
	ld h, a
	ld a, (hl+)
	; preserve bc here, so sacrifice de
	ld e, a
	ld a, (hl)
	ld h, a
	ld l, e
	inc hl
	inc hl ; hl == thisBlock.nextBlock.nextFree
	push hl
		ld a, (hl+)
		ld (bc), a
		inc bc
		ld a, (hl)
		ld (bc), a
; thisBlock.nextBlock = thisBlock.nextBlock.nextBlock
		dec bc
		dec bc
		dec bc ; thisBlock.nextBlock
	pop hl
	dec hl
	dec hl ; hl == thisBlock.nextBlock.nextBlock
	ld a, (hl+)
	ld (bc), a
	inc bc
	ld a, (hl)
	ld (bc), a
	dec bc
check_should_merge_prev$:
; if prevFree == nil ret
	ld a, (wPrevFree)
	ld e, a
	ld a, (wPrevFree + 1)
	or d
	ret z
; TODO if prevFree.nextBlock != thisBlock ret
	ld a, d
	cp b
	ret nz
	ld a, e
	cp c
	ret nz
; merge with prev block
	; TODO prevFree.nextBlock = thisBlock.nextBlock
	nop
	; TODO prevFree.nextFree = thisBlock.nextFree
	nop
	ret


	.area _DATA
wPrevFree:: .ds 2
wThisBlockPtr:: .ds 2
wNextFree:: .ds 2