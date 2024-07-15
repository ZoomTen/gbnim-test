	.module AllocFreeListRam

	.area _DATA
_prevFree::
wPrevFree:: .ds 2

_thisBlockPtr::
wThisBlockPtr:: .ds 2

_nextFree::
wNextFree:: .ds 2

	.area _HRAM (ABS)
; ASxxx limitations won't allow me to put
; HRAM areas as I would for _DATA, etc.
	.org 0xFFFD
_firstFreeBlockLow::
hFirstFreeBlock:: .ds 1
_firstFreeBlockHigh:: .ds 1
