; Implicit free-list based allocator
; Inspired by SDCC's implementation
; wHeap and wHeapEnd must be defined somewhere in WRAM

; Memory block structure:
; start struct Block
; 	dw NextBlockPtr
; 	union
; 		dw NextFreePtr # only on free blocks
; 		[]db Data # only on non-free blocks
; 	end union
; end struct Block

	.module AllocFreeList
	.area _HOME
_initMalloc::
; point first free block to beginning of heap
	ld hl, #(wHeap)
	ld a, l
	ldh (hFirstFreeBlock), a
	ld a, h
	ldh (hFirstFreeBlock + 1), a
; for the first block initially, point the "next block"
; to end of heap
	ld (hl), #(wHeapEnd)
	inc hl
	ld (hl), #(wHeapEnd >> 8)
	inc hl
	xor a
; and for its "next free block" pointer have a zero to
; mark no more free blocks left (because so far this is the only one)
	ld (hl+), a
	ld (hl), a
	ret

; SDCC calling convention
; de = how many bytes
; ret:
;	bc = 0 or pointer to next
_malloc::
; if @de[] == nil: return nil
	ld a, d
	or e
	ld bc, #0
	ret z
;; add size of header (2)
;; the 2 other bytes for "next free" can overlap
;; so we don't account for it here
	inc de
	inc de
;; ...but here, we do though
;; so the adjusted size must be >= 4
	ld a, d
	and a
	jr nz, no_adjust$
	ld a, e
	cp #4
	jr nc, no_adjust$
	ld de, #4
no_adjust$:
;; find size of this block
	ldh a, (hFirstFreeBlock)
	ld c, a
	ldh a, (hFirstFreeBlock + 1)
	ld b, a
;; bc <- hFirstFreeBlock[] == thisBlock
	ld a, (bc)
	ld l, a
	inc bc
	ld a, (bc)
	ld h, a
;; hl <- thisBlock.nextBlock[]
;; bc <- thisBlock.nextBlock + 1
	ld a, l
	sub c
	ld l, a
	ld a, h
	sbc b
	ld h, a
;; hl <- hl - bc
; if @hl <= @de: goto OOM
	ld a, h
	cp d
	jr c, after_compare$
	jr nz, after_compare$
	ld a, l
	cp e
after_compare$:
	jr c, oom$
;; we've got enough memory, reserve the next block
;; push the current next block ptr AND next free block ptr forwards
	inc bc
	inc bc
;; bc <- thisBlock.nextFree + 1
	ld l, c
	ld h, b
;; hl <- thisBlock.nextFree + 1
	add hl, de
;; space was reserved for nextFree
;; hl <- hl + de == newBlock
	.rept 3
		ld a, (bc)
		ld (hl-), a
		dec bc
	.endm
	ld a, (bc)
	ld (hl), a
;; thisBlock was copied to newBlock
;; put the address of the next block ptr at this block
;; and update the first free block ptr
	ld a, l
	ld (bc), a
	ldh (hFirstFreeBlock), a
	inc bc
	ld a, h
	ld (bc), a
	ldh (hFirstFreeBlock + 1), a
	inc bc
; bc <- the allocated data pointer
; we're done
	ret
oom$:
; return nil
	ld bc, #0
	ret

; de = `which`
;	which pointer to free?
; ret:
;	nothing
_free::
;; if which == 0: return
	ld a, d
	or e
	ret z
;; wPrevFree holds the address of a free block located prior to the
;; block that is to be freed, init here
; var prevFree #[wPrevFree]# = cast[ptr MemBlock](0)
	ld hl, #wPrevFree
	xor a
	ld (hl+), a
	ld (hl+), a
;; wThisBlockPtr holds the address to the pointer that holds a reference
;; to the currently-processed block, but we start off with the first
;; free block.
; var thisBlockPtr #[wThisBlockPtr]# = cast[ptr ptr MemBlock](firstFree.addr)
	ld (hl), #(hFirstFreeBlock)
	inc hl
	ld (hl), #(hFirstFreeBlock >> 8)
	inc hl
; var thisBlock #[bc]# = cast[ptr MemBlock](thisBlockPtr[])
	ld a, (hFirstFreeBlock)
	ld c, a
	ld a, (hFirstFreeBlock + 1)
	ld b, a
;; go through free blocks starting with the block designated the
;; first free block at this point
continue_iter$: ; while true:
; if thisBlock == nil: break
	or c
	jr z, skip_iter$
; if thisBlock >= which: break
	ld a, c
	sub e
	ld a, b
	sbc d
	jr nc, skip_iter$
; thisBlock < which, at first iteration is the first free block
; needs to be merged with the block after it that is also free
; prevFree = thisBlock
	ld hl, #wPrevFree
	ld a, c
	ld (hl+), a
	ld a, b
	ld (hl+), a
	inc bc
	inc bc ;; bc = thisBlock.nextFree
;; hl = thisBlockPtr
; thisBlockPtr = thisBlock.nextFree.addr
	ld (hl), c
	inc hl
	ld (hl), b
; thisBlock = thisBlock.nextFree
	ld l, c
	ld b, h
	ld a, (hl+)
	ld c, a
	ld a, (hl)
	jr continue_iter$
skip_iter$: ;; `bc <- thisBlock` should still hold
; var nextFree #[wNextFree]# = thisBlock
	ld hl, #wNextFree
	ld (hl), c
	inc hl
	ld (hl), b
	inc bc
	inc bc
	inc bc ;; bc <- thisBlock.nextFree + 1
	;; hl <- wNextFree + 1
; thisBlock.nextFree = nextFree
	ld a, (hl-)
	ld (bc), a
	dec bc
	ld a, (hl)
	ld (bc), a
	dec bc
	dec bc ;; bc <- thisBlock
; thisBlockPtr[] = thisBlock.addr
;; hl <- wThisBlockPtr[]
	ld a, (wThisBlockPtr)
	ld l, a
	ld a, (wThisBlockPtr + 1)
	ld h, a
;; place in wThisBlockPtr[]
	ld a, c
	ld (hl+), a
	ld a, b
	ld (hl), a
; if thisBlock.nextBlock != nextFree: # skip
;; bc <- thisBlock.nextBlock (== thisBlock)
	ld a, (bc)
	inc bc
	ld e, a
	ld a, (wNextFree)
	cp e
	jr nz, check_should_merge_prev$
	ld a, (bc)
	inc bc
	ld e, a
	ld a, (wNextFree + 1)
	cp e
	jr nz, check_should_merge_prev$
;; merge with next block
; thisBlock.nextFree = thisBlock.nextBlock.nextFree
;; bc <- thisBlock.nextFree
;; hl <- thisBlock.nextFree - 2 = thisBlock.nextBlock
	ld a, c
	sub a, #2
	ld l, a
	ld a, b
	sbc a, #0
	ld h, a
	ld a, (hl+)
;; preserve bc here, so sacrifice de
	ld e, a
	ld a, (hl)
	ld h, a
	ld l, e
	inc hl
	inc hl
;; hl <- thisBlock.nextBlock.nextFree
;; bc <- thisBlock.nextFree
	push hl
		ld a, (hl+)
		ld (bc), a
		inc bc
		ld a, (hl)
		ld (bc), a
; thisBlock.nextBlock = thisBlock.nextBlock.nextBlock
		dec bc
		dec bc
		dec bc
	pop hl
;; bc <- thisBlock.nextBlock
;; hl <- thisBlock.nextBlock.nextFree
	dec hl
	dec hl
;; hl <- thisBlock.nextBlock.nextBlock
	ld a, (hl+)
	ld (bc), a
	inc bc
	ld a, (hl)
	ld (bc), a
	dec bc
;; bc <- thisBlock.nextBlock == thisBlock
check_should_merge_prev$:
; if prevFree == nil: return
	ld a, (wPrevFree)
	ld l, a
	ld a, (wPrevFree + 1)
	or l
	ret z
	ld h, a
;; hl <- wPrevFree[] == prevFree == prevFree.nextBlock
; if prevFree.nextBlock != thisBlock return
	ld a, (hl+)
	cp c
	ret nz
	ld a, (hl-)
	cp b
	ret nz
; merge with prev block
;; bc <- thisBlock.nextBlock
;; hl <- prevFree == prevFree.nextBlock
; prevFree.nextBlock = thisBlock.nextBlock
	ld a, (bc)
	ld (hl+), a
	inc bc
	ld a, (bc)
	ld (hl+), a
	inc bc
; prevFree.nextFree = thisBlock.nextFree
;; bc <- thisBlock.nextFree
;; hl <- prevFree.nextFree
	ld a, (bc)
	ld (hl+), a
	inc bc
	ld a, (bc)
	ld (hl+), a
	inc bc
	ret
