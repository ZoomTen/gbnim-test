## This file (with this exact name) is required since we are using
## os:standalone

## These two functions need to be defined/overridden as well,
## you can put in anything here or even nothing at all

proc panic(s: string) =
  discard

proc rawoutput(s: string) =
  discard
