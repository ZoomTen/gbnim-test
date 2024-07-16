type AllocType* = enum
  ## Sets the memory allocation strategy the program will use.
  
  Arena
  ## This is a simple bump-based, stack-like memory allocator.
  ## Performant, although you cannot free memory easily--free only
  ## works on the address returned by the LAST malloc call before
  ## that point. Otherwise, it's a no-op and that memory is leaked :)
  
  FreeList
  ## A custom free-list memory allocator implemented in ASM, but
  ## inspired by SDCC's allocator.
  ## (not stable?)
  
  Sdcc
  ## SDCC's default allocator. You need to link with sm83.lib to
  ## use this.
  
  NimArena
  ## Arena but in Nim
  
  NimFreeList
  ## MyFreeList but in Nim
