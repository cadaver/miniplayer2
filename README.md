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
- Needs a much larger zeropage variable area
- Only SetMusicData (music module) operation is provided

Converter from GoatTracker 2 format included. Supported effects are 1,2,3,4,5,6 and F (no funktempo). Effect 3 (toneportamento) support is based on calculating the required slide duration, and may not work exactly in case of transposed patterns.

Use at own risk.

## License

Copyright (c) 2021 Lasse Öörni

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.