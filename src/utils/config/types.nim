## -------------------
## Configuration types
## -------------------
## 
## Types for config.nim

## .. importdoc:: ../memory.nim

type AllocType* = enum
  ## Sets the memory allocation strategy the program will use.
  ## 
  ## * **Arena** is a simple bump-based memory allocator.
  ## 
  ##   .. tip:: You can use `initMalloc()`_ to free everything.
  ## 
  ## * **StackLike** is exactly like Arena, but it keeps track of the latest
  ##   memory being allocated, therefore it comes with a `free` function.
  ##   Which only works on the address returned by the **last** malloc call.
  ##   Otherwise, it's ignored, and that memory is leaked :)
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
  StackLike
  NimArena
  NimFreeList
