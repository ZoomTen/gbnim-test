	.module AllocFreeListRam

	.area _DATA
_prevFree::
wPrevFree:: .ds 2

_thisBlockPtr::
wThisBlockPtr:: .ds 2

_nextFree::
wNextFree:: .ds 2

	.area _HRAM
_firstFreeBlockLow::
hFirstFreeBlock:: .ds 1
_firstFreeBlockHigh:: .ds 1
