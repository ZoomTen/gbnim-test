import ./vram

template print*(base: pointer, text: string) =
  ## Convenience for printing arbitrary strings to the screen.
  ## 
  ## ```nim
  ## # these `when` clauses are purely illustrative; it is
  ## # at your discretion to determine which one of these are to be used.
  ## 
  ## when LCD_is_off:
  ##   cast[pointer](BgMap0.offset(5, 0)).print("SCORE")
  ## else: # LCD is on
  ##   BgMap0.offset(5, 0).print("SCORE")
  ## ```
  when compiles(text[0].addr):
    # Text is already stored in some variable
    base.copyMem(text[0].addr, text.len)
  else:
    # Create a temporary variable ourselves
    let x = text
    base.copyMem(x[0].addr, x.len)
