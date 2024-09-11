## The heck is this?

Game Boy stuff. Written in Nim and assembly.

## How do I build this thing?

```sh
nim build
```

The generated binary should be in built.gb.

To clean up everything except the tools:

```sh
nim clean
```

To clean up everything except the .gb file:

```sh
nim cleanDist
```

## Cool, where do I start?

src/program/main.nim. That's where you'll want to start messing about.
There are two appropriately-named functions `setup` and `main`, the
latter logically being performed after the former.

## What's all this other stuff, then?

Scaffolding. This template wants to use its own runtime, not depending
too much on GBDK's. There's a ton of notes in these files, you should
read every one of them if you can.

<dl>
<dt>config.nims</dt>
<dd><p>
TODO
</p></dd>

<dt>include</dt>
<dd><p>
Include directory needed for the C side of things. At the moment this
just has a nimbase.h containing the defines needed for the Nim-generated
code to actually compile.
</p></dd>

<dt>tools</dt>
<dd><p>
Tools used when running <code>nim build</code>. Before the code is
actually built, these tools are precompiled first.
</p></dd>

<dt>tools/compile</dt>
<dd><p>
When compiling its generated C code into object files, Nim assumes
certain options and order is to be used. Fortunately, Nim allows you
to override the compiler binary being used, and we can use it to our
advantage.
</p><p>
This then just becomes a wrapper that runs the <em>actual</em> compiler
SDCC and takes care of post-processing (if any), resulting in an
.o object file in SDCC's format.
</p></dd>

<dt>tools/link</dt>
<dd><p>
Like tools/compile, this is a wrapper that runs SDCC's linker. It passes
on the same object file order that Nim generates, ensuring better chances
of the linking to be done properly.
</p></dd>

<dt>src/rom.nim</dt>
<dd><p>
This is Nim's entry point, so it's where <code>setup</code> and
<code>main</code> are called from. If we start coding here, any variables
we make here will become part of the global scope, thus ending up with
a definition in static WRAM.
</p></dd>

<dt>src/config.nim</dt>
<dd><p>
TODO
</p></dd>

<dt>src/staticRam.asm</dt>
<dd><p>
Static WRAM and HRAM definitions. We can access these primarily from
ASM, however we can also access them from Nim by prefixing the name
with <code>_</code> and decorating a variable with the <code>{.importc.}</code>
pragma.
</p></dd>

<dt>src/panicoverride.nim</dt>
<dd><p>
Currently required by Nim's <code>standalone</code> target (which is what
we're using), these are handlers for panics and the such.
</p></dd>

<dt>src/runtime</dt>
<dd><p>
Used to implement headers and the Game Boy entry point.
</p></dd>

<dt>src/utils</dt>
<dd><p>
Various small utilities for messing about with memory and things like
that.
Also includes functions to mess about with the Game Boy's hardware, which is
quite important to have any sort of input, graphics and sound.
</p></dd>
</dl>

## Why do you need a custom runtime?

Just because.
