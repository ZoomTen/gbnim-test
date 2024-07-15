import os, strutils
import ./romConfig

# Precompile "scripts"
#-------------------------------------#
proc precompileTools() =
  let tools = ["compile", "link"]

  for toolName in tools:
    let shouldRecompile =
      (
        findExe("tools" / toolName) == ""
      ) or (
        # TODO: also check if the tool src is newer than the binary
        false
      )
    
    if shouldRecompile:
      echo "make '" & toolName & "' wrapper..."
      selfExec(
        ["c", "-d:release", "--hints:off", thisDir() / "tools" / toolName & ".nim"].join(
          " "
        )
      )

#-------------------------------------#

# Setup toolchain
#-------------------------------------#
proc setupGbdk() =
  # set c compiler as ""icc"" but is actually sdcc
  switch "cc", "icc"

  # abuse the c compiler options to use a nimscript
  # for compiling, linking and finalization
  put "icc.exe", thisDir() / "tools" / "compile"
  put "icc.options.always", ""

  put "icc.linkerexe", thisDir() / "tools" / "link"
  put "icc.options.linker", ""

  # basic nim compiler options
  switch "os", (
    when false:
      ## Unfortunately this still isn't quite ready for primetime
      ## in this situation, as it still makes quite a ton of assumptions
      ## about the environment. I'm not ready for it to be deprecated
      ## any time soon.
      "any"
    else:
      ## This on the other hand, doesn't have that much overhead,
      ## is quite minimal and without a lot of assumptions, so this
      ## is what this is using.
      "standalone"
  )
  switch "gc", "arc"
  switch "cpu", "i386" # hoping this was necessary
  
  switch "define", "nimMemAlignTiny"
  when false:
    ## Using this will take up a ton of space and will
    ## actually waste your home bank with pure Nim runtime. :p
    switch "define", "nimAllocPagesViaMalloc"
    switch "define", "nimPage256"
  else:
    switch "define", "useMalloc"
  
  switch "define", "noSignalHandler"
  switch "define", "danger"
  switch "define", "nimPreviewSlimSystem"
  switch "define", "nimNoLibc"

  when useNimDebuggerLines:
    switch "debugger", "native"

  # specifics
  switch "lineTrace", "off"
  switch "stackTrace", "off"
  switch "excessiveStackTrace", "off"
  switch "overflowChecks", "off"
  switch "threads", "off"
  switch "checks", "off"
  switch "boundChecks", "on"
  switch "panics", "on"
  switch "exceptions", "goto"
  switch "noMain", "on"

#-------------------------------------#

# Set compile options specific to main file
#-------------------------------------#
if projectPath() == thisDir() / mainFile:
  setupGbdk()
  when buildCacheHere:
    switch "nimcache", "_build"
  switch "listCmd"
#-------------------------------------#

# Entry points
#-------------------------------------#
task build, "Build a Game Boy ROM":
  precompileTools()
  let args = commandLineParams()[1 ..^ 1].join(" ")
  selfExec(["c", args, "-o:" & romName & ".gb", thisDir() / mainFile].join(" "))

task clean, "Clean up this directory's compiled files":
  when buildCacheHere:
    # clean up build cache
    rmDir("_build")
    echo("removed build dir")

  # clean up compiled files
  for ext in [".gb", ".ihx", ".map", ".noi", ".sym"]:
    rmFile(romName & ext)
    echo("removed $#$#" % [romName, ext])

task cleanDist, "Clean up this directory's residual files":
  when buildCacheHere:
    # clean up build cache
    rmDir("_build")
    echo("removed build dir")

  # clean up residual files
  for ext in [".ihx", ".map", ".noi"]:
    rmFile(romName & ext)
    echo("removed $#$#" % [romName, ext])

  for ext in ["", ".exe"]:
    for toolProg in ["tools" / "compile", "tools" / "link"]:
      rmFile(toolProg & ext)
      echo("removed $#$#" % [toolProg, ext])
#-------------------------------------#
