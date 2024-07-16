const useExample = true

when useExample:
  import ./pocketClickerRemake/main as example
  export example.setup
  export example.main

else:
  import ../utils/[memory, waitLoop]
  import ../hardware/video

  proc setup*(): void =
    initMalloc()
    rStat[] = {}
    # reset scroll
    rScx[] = 0
    rScy[] = 0
    rWx[] = 7
    rWy[] = 0
    # reset palettes
    rBgp[] = NormalPalette
    rObp0[] = NormalPalette
    rObp1[] = NormalPalette
    # reset sound
    cast[ptr byte](0xff26)[] = 0
    enableLcdcFeatures(
      {win9c00, bgEnable}
    )

  ## Note: safe to do heap alloc now
  proc main*(): void =
    # your code here!
    while true:
      waitInterrupt()
