import results

type IntResult = Result[uint8, cstring]

proc runRandom(): bool =
  ## TODO: replace with GB rand func
  return true

proc getRandomInt*(): IntResult =
  if runRandom():
    return 4.ok()
  return "Whoops".cstring.err()

proc `+`*(i, n: IntResult): IntResult =
  if n.isErr():
    return n
  if not i.isErr():
    return (i.get() + n.get()).ok()
  return i

template `+`*(i: IntResult, n: uint8): IntResult =
  `+`(i, IntResult.ok(n))

when isMainModule:
  echo repr(
    getRandomInt() + 8'u8 + 9'u8 + getRandomInt() + 2'u8
  )
