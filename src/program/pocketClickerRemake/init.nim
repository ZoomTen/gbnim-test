import ./[globalState, gfx]
import ../../hardware/video
import ../../utils/print
import ../../runtime/overrides

proc gameInit*(): void {.inline.} =
  # init all
  gsState.counter = 0
  gsState.level = 0
  gsState.toNext = 0
  gsState.toNextDiff = 0
  gsState.prevButtons = {}
  gsState.nowButtons = {}
  
  # load the font
  vTiles0.offset(0x20).copyFrom(font.addr, 0x60.tiles)
  
  # these parts won't really change throughout the course of the game,
  # so we can just do it here.
  vMap0.offset(3, 1).print("Level:")
  vMap0.offset(4, 3).print("Exp:")
  vMap0.offset(1, 5).print("To next:")
  vMap0.offset(2, 14).print("POCKET CLICKER!")
  vMap0.offset(3, 16).print("Just tap A...")
  
  discard
