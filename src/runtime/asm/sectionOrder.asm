; This is to help the linker order sections in the way we want

	.module SectionOrder

	.area _HOME
	.area _OAMDMA_CODE
	.area _INITIALIZER
	.area _CODE
	
	.area _SPRITES
	.area _DATA
	.area _INITIALIZED
