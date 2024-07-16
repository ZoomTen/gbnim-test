	.module AllocStackLikeRam

	.area _HRAM
_firstFreeBlock::
hFirstFreeBlock:: .ds 2

_lastAllocatedBlock::
hLastAllocatedBlock:: .ds 2

_lastAllocationSize::
hLastAllocationSize:: .ds 2
