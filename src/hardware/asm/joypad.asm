	.include "include/hardware.inc"
	.area _HOME

;; joypad()
;; returns:
;; A = button input

_joypad::
; Read Up, Down, Left, Right
	ld a, #.P15
	ldh (rP1), a
.rept 4 ; multiple times for clarity
	ldh a, (rP1)
.endm
; Save fetched d-pad input
	cpl
	and #0b1111
	swap a
	ld b, a

; Now read A, B, Select, Start
	ld a, #.P14
	ldh (rP1), a
.rept 4 ; again, for clarity
	ldh a, (rP1)
.endm
; Combine with the previous input
	cpl
	and #0b1111
	or b
	ld b, a

; Done reading buttons
	ld a, #(.P14 | .P15)
	ldh (rP1), a

	ld a, b
	ret
