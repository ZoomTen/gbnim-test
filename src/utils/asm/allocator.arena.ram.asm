	.module AllocStackLikeRam

	.area _HRAM (ABS)
; ASxxx limitations won't allow me to put
; HRAM areas as I would for _DATA, etc.
	.org 0xFFF9
_firstFreeBlock::
hFirstFreeBlock:: .ds 2

_lastAllocatedBlock::
hLastAllocatedBlock:: .ds 2

_lastAllocationSize::
hLastAllocationSize:: .ds 2
