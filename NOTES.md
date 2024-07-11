## Entry Point

**No**:

```nim
when isMainModule:
  # game code
  discard
```

**Yes**:

```nim
proc gameCode(): void {.inline.} =
  # game code
  discard

when isMainModule:
  gameCode()
```

> [!NOTE]
> Variables defined under `when isMainModule` will become global
> variables, and will fill static RAM. Especially bad if you have
> iterators, as each one will use up static RAM. Putting it in a function
> even when inlined will make the variables use up registers first
> when it can.

## Iteration over Dereferenced Memory

**No**:

```nim
for i in 0xc000'u16..0xd000'u16:
  cast[ptr byte](j)[] = 0
```

**Yes**:

```nim
var i = 0xc000'u16
while i < 0xd000'u16:
  cast[ptr byte](i)[] = 0
  i += 1'u16
```

> [!NOTE]
> The former one produces more C code than the latter, and SDCC isn't
> THAT smart at recognizing this kind of pattern, so it will be reflected
> in the ASM. It's one case where *idiomatic* Nim makes the codegen sadder
> than it is :(

The former makes code like:
```asm
	ld	bc, #0xc000
00110$:
	ld	e, b
	ld	d, #0xd0
	xor	a, a
	cp	a, c
	ld	a, #0xd0
	sbc	a, b
	bit	7, e
	jr	Z, 00146$
	bit	7, d
	jr	NZ, 00147$
	cp	a, a
	jr	00147$
00146$:
	bit	7, d
	jr	Z, 00147$
	scf
00147$:
	jp	C,_nimTestErrorFlag
	ld	l, c
	ld	h, b
	ld	(hl), #0x00
	inc	bc
	jr	00110$
```

While the latter makes code like:
```nim
	ld	bc, #0xc000
00104$:
	ld	a, b
	sub	a, #0xd0
	jr	NC, 00106$
	ld	l, c
	ld	h, b
	ld	(hl), #0x00
	inc	bc
	jr	00104$
00106$:
```

## Function arguments

SDCC can only support a maximum of 2 arguments before using the stack.
See SDCC manual pages 75&ndash;76.

Nim arguments map neatly to C arguments, so this same limitation
applies.
