type
  rNr52Flag* = enum
    Ch1Enable = 0
    Ch2Enable
    Ch3Enable
    Ch4Enable
    nr52f4 # unused
    nr52f5 # unused
    nr52f6 # unused
    EnableAll = 7
  rNr52Flags* = set[rNr52Flag]
  
  rNr51Output* = enum
    Ch1R = 0
    Ch2R
    Ch3R
    Ch4R
    Ch1L
    Ch2L
    Ch3L
    Ch4L
  rNr51Outs* = set[rNr51Output]

const
  rNr51* = cast[ptr rNr51Outs](0xff25)
  rNr52* = cast[ptr rNr52Flags](0xff26)

const
  AudioMasterControl* = rNr51
  SoundPanning* = rNr52
