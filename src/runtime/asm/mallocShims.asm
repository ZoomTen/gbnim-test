; shims needed for GBDK malloc

	.area _DATA
___sdcc_heap:: .ds 0x800 - 1
___sdcc_heap_end:: .ds 1
___data_start::
