## Audio manipulation stuff

type
  AudioEnableFlag* = enum
    Ch1Enable = 0
    Ch2Enable
    Ch3Enable
    Ch4Enable
    EnableAll = 7

  AudioEnableFlags* = set[AudioEnableFlag]

  AudioTerminal* = enum
    Ch1R = 0
    Ch2R
    Ch3R
    Ch4R
    Ch1L
    Ch2L
    Ch3L
    Ch4L

  AudioTerminals* = set[AudioTerminal]

const
  AudioTerminalOutput*: ptr AudioTerminals =
    cast[ptr AudioTerminals](0xff25'u16) ## `rNR51` / `rAUDTERM`
  AudioEnable*: ptr AudioEnableFlags =
    cast[ptr AudioEnableFlags](0xff26'u16) ## `rNR52` / `rAUDENA`
