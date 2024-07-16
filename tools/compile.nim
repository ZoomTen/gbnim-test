## Mimics icc for compiling. Its purpose is to discern between
## C sources and ASM sources and makes it somewhat manageable.
##
## Calls sdcc directly.
##
## Compilation is slow, but I guess that's the kinda
## price to pay for *full* control over the C compiler invocation.
## *shrug*

## If you have modified the location of call_HL in
## src/runtime/asm/hwVectors.asm, edit this and recompile.
##
## This is because SDAS/ASxxxx only supports rst $xx as an instruction
## in and of itself, and not magical "oh that label actually coincides
## with a valid vector" like, say, RGBASM does.
##
## Oh, the things I do to optimize mid codegen...
const callHlRstLocation = 0x00

import std/os
import std/strutils
import ./helpers
import std/syncio

template runCc(gbdkRoot, infile, outfile: string) =
  execWithEcho(
    (@[
      gbdkRoot / "bin" / "sdcc",
      "-S", # compile only
      # basic includes
        "-I" & gbdkRoot / "include", # gbdk libraries
        "-I" & getCurrentDir() / "include", # our stuff and our nimbase.h
      # target architecture
        "-msm83",
        "-D" & "__TARGET_gb",
        "-D" & "__PORT_sm83",
      "--opt-code-speed",
      "--max-allocs-per-node", "10000",
      # LCC defaults
        "--no-std-crt0",
        "--fsigned-char",
        "-Wa-pogn",
      # which files
        "-o", outfile,
        infile
    ]).join(" ")
  )

template runAsm(gbdkRoot, infile, outfile: string) =
  execWithEcho(
    (@[
      gbdkRoot / "bin" / "sdasgb",
      "-l", # generate listing
        "-I" & getCurrentDir() / "include", # our stuff and our nimbase.h
      # LCC defaults
        "-pogn",
        "-o", outfile,
        infile
    ]).join(" ")
  )

when isMainModule:
  let gbdkRoot = getGbdkRoot()
  var inputs = commandLineParams().join(" ").paramsToSdldInput()

  # I would hope this was invoked as 1 source file = 1 object file
  let
    (outfDir, outfName, outfExt) = inputs.outputFile.splitFile()
    (srcfDir, srcfName, srcfExt) = inputs.objFiles[0].splitFile()
  
  case srcfExt.toLowerAscii()
  of ".c":
    # run SDCC if we get a C file
    let
      intermediateAsmOut = outfDir / outfName & ".asm"
      actualOut = outfDir / outfName & outfExt
    
    gbdkRoot.runCc(srcfDir / srcfName & srcfExt, intermediateAsmOut)
    # post process the resulting file
    var asmFile = ""
    for line in intermediateAsmOut.lines:
      asmFile.add(
        (
          line
          # optimize out "call hl" calls into a rst
          .replace(
            "\tcall\t___sdcc_call_hl",
            "\trst\t0x" & callHlRstLocation.toHex(2)
          )
          # I'm doing piecewise stdlib replacement
          # patch out any call to malloc and free
          #.replaceWord(
          #  "_malloc",
          #  "_myMalloc"
          #)
          #.replaceWord(
          #  "_free",
          #  "_myFree"
          #)
          #.replaceWord(
          #  "_calloc",
          #  "_myCalloc"
          #)
        ) & '\n'
      )
    writeFile(intermediateAsmOut, asmFile)
    gbdkRoot.runAsm(intermediateAsmOut, actualOut)
  of ".asm", ".s":
    # run SDAS if we get an ASM file
    gbdkRoot.runAsm(
      srcfDir / srcfName & srcfExt,
      outfDir / outfName & outfExt
    )
  else:
    raise newException(CatchableError, "unknown format")
