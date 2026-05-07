# Resources/Sounds

Drop ambient audio files here to upgrade the procedural fallbacks from
`AudioEngine`. Files take precedence over the synth — when a matching
file is present, sessions play the recording; when absent, the engine
falls back to the procedural generator (or silence for unsupported ids).

## Naming convention

The file's name (without extension) must match the `fileName` declared
in `SoundCatalog.swift`:

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
| `suikinkutsu`     | `suikinkutsu`          |

The session bell (rung at start + end) also looks for a bundled
`bell.{caf,m4a,mp3,wav}`. When present, it replaces the synthesized
bell from `BellSynth`. Use the same naming convention as the catalog
sounds.

`noise.white` / `noise.pink` / `noise.brown` and `silence` have no
`fileName` — they're always procedural.

## File format

Tried in order: `.caf` → `.m4a` → `.mp3` → `.wav`. Pick whichever is
most convenient. The current bundle uses `.m4a` (AAC in MP4) since
`afconvert` / `ffmpeg`'s AAC-in-CAF path is fragile; `.m4a` is iOS-native.

Recommended: 96 kbps mono AAC. For an ambient bed mono is plenty,
and 96 kbps is the sweet spot between artifacts and size.

```sh
ffmpeg -i input.ogg -c:a aac -b:a 96k -ac 1 output.m4a
```

## Length

Aim for **30 s – 2 min** of seamlessly-loopable content per sound. The
engine reads the file fully into memory and loops via
`scheduleBuffer(.loops)`. For seamless loops, edit so the start sample
matches the end sample (crossfade the last 1 s onto the first 1 s of
itself in Audacity → Effect → Crossfade Tracks).

## Where to find files

- **commons.wikimedia.org** — Public Domain / CC-BY / CC-BY-SA, direct
  download URLs (predictable upload.wikimedia.org/wikipedia/commons/X/XY/Filename
  pattern). Best source for tibetan bowls, om chants, nature recordings.
- **archive.org** — public domain audio collections, long-form recordings.
- **freesound.org** — large CC-licensed library, requires account.
- **pixabay.com/sound-effects** — royalty-free, no attribution required.
- **mixkit.co/free-sound-effects** — clean catalog, free for commercial use.

## Adding a file

1. Drop `your-sound.m4a` (matching the catalog name) into this directory.
2. Run `xcodegen generate` from the project root — xcodegen picks up the
   file and adds it to the bundle's resources phase.
3. Build & run. Pick the sound in the library; you'll hear the recording
   instead of the procedural fallback.

To revert to the procedural version, just delete the file and regenerate.

## Bundled files

| File                | Source                                   | Artist                            | License            |
|---------------------|------------------------------------------|-----------------------------------|--------------------|
| `tibetan-bowls.m4a` | [Wikimedia](https://commons.wikimedia.org/wiki/File:Small_tibetan_singing_bowl.ogg) | Cassa342                          | CC BY-SA 4.0       |
| `ocean-waves.m4a`   | [Wikimedia](https://commons.wikimedia.org/wiki/File:Waves.ogg) | Dsw4                              | Public Domain      |
| `forest.m4a`        | [Wikimedia](https://commons.wikimedia.org/wiki/File:20090610_0_ambience.ogg) | nille                             | Public Domain      |
| `fire.m4a`          | [Wikimedia](https://commons.wikimedia.org/wiki/File:Campfire_sound_ambience.ogg) | Glaneur de sons (freesound.org)   | CC BY 3.0          |
| `rain-light.m4a`    | [Wikimedia](https://commons.wikimedia.org/wiki/File:Rain_against_the_window.ogg) | cori                              | Public Domain      |
| `temple.m4a`        | [Wikimedia](https://commons.wikimedia.org/wiki/File:Monks_chanting,_Drepung_monastery,_Tibet.webm) | Maris Burbergs                    | CC BY 3.0          |
| `om-chant.m4a`      | [Wikimedia](https://commons.wikimedia.org/wiki/File:Schola_Gregoriana-Pater_Noster.ogg) | Schola Gregoriana                 | CC BY-SA 3.0       |
| `bell.m4a`          | [Wikimedia](https://commons.wikimedia.org/wiki/File:Meditation_Gong.ogg) | Marble Toast                      | CC0                |
| `suikinkutsu.m4a`   | [Wikimedia](https://commons.wikimedia.org/wiki/File:Suikinkutsu-LS100128.ogg) | Fg2                               | Public Domain      |
| `rain-heavy.m4a`    | [Wikimedia](https://commons.wikimedia.org/wiki/File:Regen_op_een_pannendak_-_SoundCloud_-_Beeld_en_Geluid.ogg) | Beeld en Geluid (NL audiovisual archive) | CC BY-SA 3.0 |
| `river.m4a`         | [Wikimedia](https://commons.wikimedia.org/wiki/File:Water_on_Rocks.ogg) | Dsw4                              | CC BY 3.0          |
| `wind.m4a`          | [Wikimedia](https://commons.wikimedia.org/wiki/File:Howling_wind.ogg) | Tvabutzku1234                     | CC0                |

The CC-licensed files (BY / BY-SA) require attribution somewhere in the
shipping app — typically a "Sound credits" entry in the About / Acknowledgements
screen.

### Still procedural (no recording yet)

- `ocean.shore` — same generator as `ocean.waves` with slower LFO period
- `noise.*` — always procedural by design (they're math, not recordings)
