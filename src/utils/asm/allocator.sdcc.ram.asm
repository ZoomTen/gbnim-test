; shims needed for GBDK malloc
	.module AllocSdccRam

	.area _DATA
___sdcc_heap:: .ds 0x800 - 1
___sdcc_heap_end:: .ds 1

