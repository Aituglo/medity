# Resources/Sounds

Drop ambient audio files here to upgrade the procedural fallbacks from
`AudioEngine`. Files take precedence over the synth — when a matching
file is present, sessions play the recording; when absent, the engine
falls back to the procedural generator (or silence for the Sacred set).

## Naming convention

The file's name (without extension) must match the `fileName` declared
in `SoundCatalog.swift`. Mapping reference:

| Sound id          | Expected file name     |
|-------------------|------------------------|
| `rain.light`      | `rain-light`           |
| `rain.heavy`      | `rain-heavy`           |
| `ocean.waves`     | `ocean-waves`          |
| `ocean.shore`     | `ocean-shore`          |
| `forest`          | `forest`               |
| `river`           | `river`                |
| `fire`            | `fire`                 |
| `wind`            | `wind`                 |
| `tibetan-bowls`   | `tibetan-bowls`        |
| `om-chant`        | `om-chant`             |
| `temple`          | `temple`               |

`noise.white` / `noise.pink` / `noise.brown` and `silence` have no
`fileName` — they're always procedural.

## File format

Tried in order: `.caf` → `.m4a` → `.mp3` → `.wav`. Pick whichever is
most convenient.

- **`.caf`** — Apple's preferred container. Smallest decode cost. Convert
  with: `afconvert -f caff -d aac -b 96000 input.wav output.caf`
- **`.m4a`** — best size/quality trade-off; AAC at ~96 kbps is plenty for
  ambient.
- **`.mp3`** / **`.wav`** — work, but heavier. `.wav` will balloon the app size.

## Length

Aim for **30 s – 2 min** of seamlessly-loopable content per sound. The
engine reads the file fully into memory and loops via
`scheduleBuffer(.loops)`, so very long files cost RAM. Short looped
files are perfect — in a meditation context the loop point being noticeable
is the only quality concern.

For seamless loops, edit so the start sample matches the end sample
(crossfade the last 1 s onto the first 1 s of itself).

## Where to find files (free / CC / royalty-free)

- **freesound.org** — huge CC-licensed library. Best for nature recordings.
  Search "rain", "ocean waves", "tibetan bowl", "om chant", etc.
  *Check each file's license — most are CC0 or CC-BY (attribution required).*
- **pixabay.com/sound-effects** — royalty-free, no attribution required.
- **mixkit.co/free-sound-effects** — clean catalog, free for commercial use.
- **soundbible.com** — public-domain mixed bag.
- **bbc.co.uk/sound-effects** — BBC archive, free for personal/educational
  (commercial requires a license).
- **zapsplat.com** — free with account, attribution required.

## Adding a file

1. Drop `rain-light.caf` (or any matching name) into this directory.
2. Run `xcodegen generate` from the project root — xcodegen will pick up
   the file and add it to the bundle's resources phase.
3. Build & run. Pick the sound in the library; you'll hear the recording.

To remove and fall back to the procedural version, just delete the file
and regenerate.

## Attribution

Track license info for each file in this README so we don't lose it.
Format:

```
- rain-light.caf — freesound.org/people/<author>/sounds/<id>/ — CC-BY 3.0
```

(Append entries below as you add files.)

### Files

(none yet)
