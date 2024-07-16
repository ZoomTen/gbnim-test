import ../../hardware/joypad

type
  State = object
    counter*: uint32
    level*: uint8
    toNext*: uint32
    toNextDiff*: uint32
    prevButtons*: JoypadButtons
    nowButtons*: JoypadButtons

var gsState*: State
    
