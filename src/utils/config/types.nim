## .. importdoc:: ../memory.nim

type AllocType* = enum
  ## Sets the memory allocation strategy the program will use.
  ## 
  ## * **Arena** is a simple bump-based, stack-like memory allocator.
  ##   Performant, although you cannot free memory easily—free only
  ##   works on the address returned by the LAST malloc call before
  ##   that point. Otherwise, it's a no-op and that memory is leaked :)
  ## 
  ##   .. tip:: You can use `initMalloc()`_ to free everything.
  ## 
  ## * **FreeList** is a custom free-list memory allocator implemented in ASM, but
  ##   inspired by SDCC's allocator.
  ## 
  ## * **Sdcc** is… well, SDCC's default allocator. To use this, you need to link
  ##   with GBDK 2020's sm83.lib.
  ## 
  ## * **NimArena**. Same as Arena, but in Nim. This is not implemented yet.
  ## 
  ## * **NimFreeList**. Same as FreeList, but in Nim. Still needs some work, not very useable yet.
  Arena
  FreeList
  Sdcc
  NimArena
  NimFreeList
