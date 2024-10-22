; The Game Boy header
	.include "include/header.inc"
	.area _HEADER (ABS)

.org 0x100 ; Entry point
	jp Init

.org 0x104 ; Nintendo logo
	.byte 0xCE,0xED,0x66,0x66
	.byte 0xCC,0x0D,0x00,0x0B
	.byte 0x03,0x73,0x00,0x83
	.byte 0x00,0x0C,0x00,0x0D
	.byte 0x00,0x08,0x11,0x1F
	.byte 0x88,0x89,0x00,0x0E
	.byte 0xDC,0xCC,0x6E,0xE6
	.byte 0xDD,0xDD,0xD9,0x99
	.byte 0xBB,0xBB,0x67,0x63
	.byte 0x6E,0x0E,0xEC,0xCC
	.byte 0xDD,0xDC,0x99,0x9F
	.byte 0xBB,0xB9,0x33,0x3E

.org 0x134 ; ROM title <filled out by tooling>

.org 0x143 ; CGB flag
; 0x00 = Grey brick Game Boy only
; 0x80 = Game Boy Color support, but backwards compatible
; 0xC0 = Game Boy Color only
	.byte .DMG

.org 0x144 ; New licensee code
	.byte "zu"

.org 0x146 ; SGB flag
; 0x03 = Enable Super Game Boy features
; else = No Super Game Boy features
	.byte .SGB

.org 0x147 ; Cart type
	.byte .ROM

.org 0x148 ; ROM size <filled out by tooling>

.org 0x149 ; RAM size
	.byte .RAM_0_BANKS

.org 0x14a ; Destination
	.byte .DEST_INTL

.org 0x14b ; Old licensee code
	.byte 0x33 ; "Use new licensee code"

.org 0x14c ; ROM version
	.byte 0x00

.org 0x14d ; Header checksum <filled out by tooling>

.org 0x14e ; Global checksum <filled out by tooling>
