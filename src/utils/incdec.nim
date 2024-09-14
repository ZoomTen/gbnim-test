## Codegen helpers for optimizing increment and decrement operations.
## 
## Nim's `inc` operator gets compiled into `something += (NI) 1`. To SDCC,
## this will be pretty much just `something++` for value-types or something
## already in the register, but for indirect variables, this will result in
## a lot more code.
## 
## For these use cases, we will have to emit some C manually. These macros
## override the declarations in `system`, so it is just drop-in.

import std/macros

macro inc*(variable: var SomeInteger): untyped =
  let prag = nnkPragma.newTree(
    nnkExprColonExpr.newTree(
      newIdentNode("emit"),
      nnkInfix.newTree(
        newIdentNode("&"), newLit(variable.strval), newLit("++;")
      ),
    )
  )
  result = newStmtList()
  result.add(prag)

macro dec*(variable: var SomeInteger): untyped =
  let prag = nnkPragma.newTree(
    nnkExprColonExpr.newTree(
      newIdentNode("emit"),
      nnkInfix.newTree(
        newIdentNode("&"), newLit(variable.strval), newLit("--;")
      ),
    )
  )
  result = newStmtList()
  result.add(prag)
