## This file (with this exact name) is required since we are using
## os:standalone

## These two functions need to be defined/overridden as well,
## you can put in anything here or even nothing at all

proc rawoutput(s: string) =
  # TODO: replace this with a proper
  # crash screen
  var pt: uint16 = 0xc000
  for i in 0 ..< len(s):
    cast[ptr char](pt)[] = s[i]
    inc pt

proc panic(s: string) =
  rawoutput(s)
  asm """stop"""
