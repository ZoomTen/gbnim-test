(SDC)C does stackplay:

void test(void) {
	/*
	 * At the beginning of the function, it will
	 * reserve sizeof(test) bytes from the stack
	 * 
	 * test:
	 *     add sp, -5
	 * 
	 * ; and returns the stack right after
	 *     add sp, 5
	 *     ret
	 */
	struct {
		uint8_t a;
		uint16_t b;
		int c;
	} k;
	
	/*
	 * If you initialize it...
	 * 
	 * test:
	 * ; allocate
	 *     add sp, -5
	 * 
	 *     ld hl, sp + 0
	 * ; clear .a
	 *     xor a
	 *     ld [hli], a
	 * ; clear .b
	 *     xor a
	 *     ld [hli], a
	 *     ld [hli], a
	 * ; clear .c
	 *     xor a
	 *     ld [hli], a
	 *     ld [hl], a
	 * ; free
	 *     add sp, 5
	 *     ret
	 */
	struct {
		uint8_t a;
		uint16_t b;
		int c;
	} k = { 0 };
	
	/*
	 * let's assign stuff to it
	 * 
	 * ...
	 * ; k.test2 = 0x1234
	 *     ld hl, sp + 1
	 *     ld a, $34
	 *     ld [hli], a
	 *     ld [hl], $12
	 * 
	 * ; k.nnn = 0xabcd
	 *     ld hl, sp + 3
	 *     ld [hl], $cd
	 *     inc hl
	 *     ld [hl], $ab
	 * ...
	 */
	k.test2 = 0x1234;
	k.nnn = 0xabcd;
}
