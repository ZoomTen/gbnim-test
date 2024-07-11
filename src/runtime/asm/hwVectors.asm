	.area _VECTORS (ABS)
.org 0x00
vec_00:: nop

.org 0x08
vec_08:: nop

.org 0x10
vec_10:: nop

.org 0x18
vec_18:: nop

.org 0x20
vec_20:: nop

.org 0x28
vec_28:: nop

.org 0x30
vec_30:: nop

.org 0x38
; 0xFF = rst 0x38, can put a crash handler here
vec_38:: nop

.org 0x40 ; vblank
vec_Vblank:: reti

.org 0x48 ; LCD
vec_LCD:: reti

.org 0x50 ; Timer
vec_Timer:: reti

.org 0x58 ; Serial
vec_Serial:: reti

.org 0x60 ; Joypad
vec_Joypad:: reti
