## Macros for SDCC-specific features.

import std/macros
export macros

# i can't yet find a way to make bank numbers a Nim pragma
# so {.emit: "#pragma bank N".} will have to do for now.

template codeGenMacro(appendString: string) {.dirty.} =
  ## thanks @rockcavera!
  result = newStmtList()
  if node.kind notIn [nnkProcDef, nnkFuncDef, nnkVarSection]:
    result.add(node)
    return
  if node.kind == nnkVarSection: # TODO tidy this up...
    for i in node:
      for j in i:
        for k in j:
          if k.kind == nnkPragma:
            k.add(
              nnkExprColonExpr.newTree(
                newIdentNode("codegenDecl"), newLit(appendString)
              )
            )
  else:
    # silly: if a codegen pragma already exists, add the thing to it
    for child in node:
      if child.kind == nnkPragma:
        for pragma in child:
          if pragma.kind == nnkExprColonExpr:
            if pragma[0] == newIdentNode("codegenDecl"):
              pragma[1] = newLit(pragma[1].strval & " " & appendString)
              result.add(node)
              return
    # otherwise, add the pragma
    node.addPragma(
      nnkExprColonExpr.newTree(
        newIdentNode("codegenDecl"), newLit(appendString)
      )
    )
  result.add(node)

macro banked*(node: untyped): untyped =
  ## Declares a proc as banked.
  when false:
    if node.kind notIn [nnkProcDef, nnkFuncDef]:
      {.error: "this macro only works for procs".}
  codeGenMacro("$# $# $# BANKED")

macro oldCall*(node: untyped): untyped =
  ## Declares a proc that uses the SDCC v0 convention. For reference,
  ## the default convention used is SDCC v1.
  when false:
    if node.kind notIn [nnkProcDef, nnkFuncDef]:
      {.error: "this macro only works for procs".}
  codeGenMacro("$# $# $# __sdcccall(0)")

macro asmDefined*(node: untyped): untyped =
  ## Declares a var that has been allocated statically; i.e. defined
  ## explicitly in WRAM.
  when false:
    if node.kind notIn [nnkVarSection]:
      {.error: "this macro only works for vars".}
  codeGenMacro("extern volatile $# $#")

macro hramByte*(node: untyped): untyped =
  ## Declares a byte var in HRAM.
  when false:
    if node.kind notIn [nnkVarSection]:
      {.error: "this macro only works for vars".}
  codeGenMacro("extern volatile __sfr /* $# */ $#")
