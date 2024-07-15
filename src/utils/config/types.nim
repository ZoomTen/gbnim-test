type AllocType* = enum
  ## This is a simple bump-based, stack-like memory allocator.
  ## Performant, although you cannot free memory easily--free only
  ## works on the address returned by the LAST malloc call before
  ## that point. Otherwise, it's a no-op and that memory is leaked :)
  Arena
  
  ## A custom free-list memory allocator implemented in ASM, but
  ## inspired by SDCC's allocator.
  ## (not stable?)
  FreeList
  
  ## SDCC's default allocator. You need to link with sm83.lib to
  ## use this.
  Sdcc
  
  ## Arena but in Nim
  NimArena
  
  ## MyFreeList but in Nim
  NimFreeList
