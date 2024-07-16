; Value of A on boot-up
.IS_DMG = 0x01 ; Game Boy or Super Game Boy
.IS_MGB = 0xFF ; Game Boy Pocket or SGB 2
.IS_CGB = 0x11 ; Game Boy Color

; Joypad
rP1 = 0xFF00
.P1F_5 = 0b00100000 ; P15 out port, set to 0 to get buttons
.P1F_4 = 0b00010000 ; P14 out port, set to 0 to get dpad
.P1F_3 = 0b00001000 ; P13 in port
.P1F_2 = 0b00000100 ; P12 in port
.P1F_1 = 0b00000010 ; P11 in port
.P1F_0 = 0b00000001 ; P10 in port
.P1F_GET_DPAD = 0b00100000
.P1F_GET_BTN = 0b00010000
.P1F_GET_NONE = 0b00110000
.UP = 0x04
.DOWN = 0x08
.LEFT = 0x02
.RIGHT = 0x01
.A = 0x10
.B = 0x20
.SELECT  = 0x40
.START = 0x80
.P14 = 0x10
.P15 = 0x20
