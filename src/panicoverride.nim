## This file (with this exact name) is required since we are using
## os:standalone

## These two functions need to be defined/overridden as well,
## you can put in anything here or even nothing at all

import hardware/video

proc panic (s: string) =
# test
    vMap0.copyFrom(s[0].addr, s.len)

proc rawoutput (s: string) = discard
