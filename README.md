# Minimal C64 music player v2

9- or 10-rasterline player with limited featureset.

- Wave / pulse / filtertables with "next column" instead of jumps
- Delayed step, slide (indefinite) and vibrato commands in wavetable
- Pulse and filter tables are based on "destination value compare" instead of time counters
- Normal & legato instruments
- Pattern commands to change waveform, ADSR and wavetable pointer
- Transpose
- Optional sound FX support, allows music to continue underneath
- Support for several music modules with the same player code, similar to NinjaTracker gamemusic mode

Disadvantages:

- Only 1 frame of gateoff before new note (does not guarantee proper hard restart)
- Skips pulsetable execution when reading new note data or new sequencer step
- Pulse & filter tables can be only 127 steps, due to high bit of position indicating "init" step

Differences to the original miniplayer:

- Does not skip wavetable execution when reading new note data (e.g. during a long note or keyoff)
- Different hard restart, sets gate off for 1 frame and sustain-release to $0f
- Added support for changing ADSR during a note
- No waveform register shadowing. Keyoffs are implemented as a direct waveform change
- Music must be page-aligned and music data may be larger
- By default, needs a much larger zeropage variable area. Extra ZP usage can be disabled but this makes the player slower

Converter from GoatTracker 2 format included. Supported effects are 1,2,3,4,5,6 and F (no funktempo). Effect 3 (toneportamento) support is based on calculating the required slide duration, and may not work exactly in case of transposed patterns.

Use at own risk.

## How to use

Include the player source code player.s in your program. It is in DASM format. Note the configuration instructions in the beginning.

### Convert a GT2 song into sourcecode, music module mode (default)

Music modules must be page-aligned (address lowbyte 0.)

```
gt2mini2 yoursong.sng yoursong.s
```

### Convert a GT2 song into sourcecode, single music only

In this case music should be assembled together with the player (AKA bare mode). Note that also in this case music data must be page-aligned.

```
gt2mini2 yoursong.sng yoursong.s -b
```

### Set a new music module into use

```
lda #$ff
sta PlayRoutine+1 ;Make sure playroutine outputs silence in the meanwhile
lda #<musicData ;Must be 0
ldx #>musicData
jsr SetMusicData
```

### Start playing a subtune

```
lda #subtune+1 ;1 corresponds to the first subtune
sta PlayRoutine+1
```

### Play one frame of music

```
jsr PlayRoutine
```

### Play a sound effect

Sound effect data must not pagecross. Playroutine must not be called in between the low and high pointer writes (ensure with SEI instruction if necessary). When the sound effect finishes, chnSfxPtrHi becomes 0 and music resumes on the channel.

```
ldx #0 ;Channel index. Should be 0, 7 or 14 for channels 1-3
lda #<soundFXData
sta chnSfxPtrLo,x
lda #>soundFXData
sta chnSfxPtrHi,x
```

Check prgexample.s for an example sound effect. You must also define slide speed tables (sfxSlideTblLo & sfxSlideTblHi) so that the player
will assemble correctly with sound effect support enabled.

## License

Copyright (c) 2023 Lasse Öörni

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.