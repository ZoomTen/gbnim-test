import ../hardware/video

template print*(base: ptr VramTilemap, text: string) =
  ## Convenience for printing arbitrary strings to the screen.
  when compiles(text[0].addr):
    # Text is already stored in some variable
    base.copyFrom(text[0].addr, text.len)
  else:
    # Create a temporary variable ourselves
    let x = text
    base.copyFrom(x[0].addr, x.len)
