; Header constants
; Convention: starts with . = part of an enum
;             starts with _ = can be imported from C or Nim

; 0x143 - Game Boy type
.DMG = 0x00
.GBC_COMPAT = 0x80
.GBC = 0xC0

; 0x146 - Super Game Boy support
.SGB = 0x03
.NO_SGB = 0x00

; 0x147 - Cartridge mapper
.ROM = 0x00
.MBC1 = 0x01
.MBC1_RAM = 0x02
; TODO

; 0x149 - RAM size
.RAM_0_BANKS  = 0x00
.RAM_1_BANK   = 0x02
.RAM_4_BANKS  = 0x03
.RAM_8_BANKS  = 0x05
.RAM_16_BANKS = 0x04

; 0x14A - Destination
.DEST_JP   = 0x00
.DEST_INTL = 0x01
