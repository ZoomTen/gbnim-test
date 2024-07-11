; structure of block:
; 	<pointer to next block or end of heap>
; 	<block's data or some pointer idk>

	.area _HOME
myMallocInit::
	; point first free block to beginning of heap
	ld hl, #(wMyHeap)
	ld a, l
	ldh (hFirstFreeBlock), a
	ld a, h
	ldh (hFirstFreeBlock + 1), a
	; for the first block initially, point the "next free" block
	; to end of heap
	ld (hl), #(wMyHeapEnd)
	inc hl
	ld (hl), #(wMyHeapEnd >> 8)
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
	inc de
	inc de
; adjusted size must be >= 4
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
	jr c, afcompare$
	jr nz, afcompare$
	ld a, l
	cp e
afcompare$:
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

_free::
	ret

_memset::
	ret
