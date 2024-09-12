	.module HwVectors

	.area _VECTORS (ABS)
.org 0x00
vec_00::
;; WARNING: The location of call_HL is used to replace
;; `call __sdcc_call_hl` with an rst instruction!
;;
;; If you move this, be sure to update tools/compiler.nim.
call_HL::
	jp (hl)

.org 0x08
vec_08::
MemcpySmall::
;; Copy from DE to HL for C bytes
	ld a, (de)
	ld (hl+), a
	inc de
	dec c
	jr nz, MemcpySmall
	ret

.org 0x10
vec_10::
MemsetSmall::
;; fill HL for C bytes with A
	ld (hl+), a
	dec c
	jr nz, MemsetSmall
	ret

.org 0x18
; not used
vec_18:: nop

.org 0x20
; not used
vec_20:: nop

.org 0x28
; not used
vec_28:: nop

.org 0x30
; not used
vec_30:: nop

.org 0x38
; 0xFF = rst 0x38, can put a crash handler here
vec_38:: nop

.org 0x40 ; vblank
vec_Vblank::
	jp _vblank

.org 0x48 ; LCD
vec_LCD:: reti

.org 0x50 ; Timer
vec_Timer:: reti

.org 0x58 ; Serial
vec_Serial:: reti

.org 0x60 ; Joypad
vec_Joypad:: reti

; beyond here is what's called "high HOME"
; it's a small bit of space before the header
; that you could use for utilities.
