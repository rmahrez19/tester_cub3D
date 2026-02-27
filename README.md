# tester_cub3D

A test suite for the **cub3D** project — a 42 school raycasting engine written in C.
This folder contains a collection of map files (valid and invalid), the associated textures,
and a shell script that automatically tests your `cub3D` binary against all of them.

---

## Folder structure

```
tester_cub3D/
├── map/
│   ├── good/          # 21 valid maps — cub3D should open and run them
│   └── bad/           # 30 invalid maps — cub3D should exit with an error
├── data/
│   └── texture/       # 20 XPM texture files used by the maps
├── .picture/          # Screenshots / visual references
├── test_maps.sh       # Automated test runner
└── README.md
```

---

## How to run the tests

Place `tester_cub3D/` next to your compiled `cub3D` binary, then run:

```bash
bash tester_cub3D/test_maps.sh
```

The script launches `./cub3D` on every map and checks whether it keeps running (expected for
`good/` maps) or exits with an error (expected for `bad/` maps). It prints a colour-coded
`PASS` / `FAIL` result for each map.

> **Note:** the binary must be located at `./cub3D` relative to your working directory
> (i.e. the root of your cub3D project).

---

## Map file format (`.cub`)

Each `.cub` file is a plain-text configuration file made of two sections:

1. **Header** — texture paths and floor/ceiling colours (order is flexible, blank lines allowed)
2. **Map grid** — a 2-D grid of characters, must come last in the file

### Texture identifiers

| Identifier | Meaning                          | Expected value              |
|------------|----------------------------------|-----------------------------|
| `NO`       | North wall texture               | Path to a `.xpm` file       |
| `SO`       | South wall texture               | Path to a `.xpm` file       |
| `WE`       | West wall texture                | Path to a `.xpm` file       |
| `EA`       | East wall texture                | Path to a `.xpm` file       |
| `F`        | Floor colour (RGB)               | `R,G,B` — values 0–255      |
| `C`        | Ceiling colour (RGB)             | `R,G,B` — values 0–255      |

**Example header:**

```
NO  tester_cub3D/data/texture/wall_north.xpm
SO  tester_cub3D/data/texture/wall_south.xpm
WE  tester_cub3D/data/texture/wall_west.xpm
EA  tester_cub3D/data/texture/wall_east.xpm

F 18,53,25
C 153,204,255
```

> All texture paths are relative to the directory from which `cub3D` is executed.

### Map grid characters

| Character      | Meaning                                      |
|----------------|----------------------------------------------|
| `1`            | Wall                                         |
| `0`            | Empty floor (walkable)                       |
| `N` / `S` / `E` / `W` | Player start position and facing direction |
| ` ` (space)    | Void (treated as outside the map)            |

**Rules:**
- The map must be fully enclosed by walls (`1`s) — no open edges
- Exactly **one** player start position must be present
- The map section must be the **last** block in the file (nothing after it)
- Leading whitespace and blank lines are allowed in the header

---

## Bad maps — what each test covers

| File | Error type |
|------|-----------|
| `color_invalid_rgb.cub` | RGB value out of range (e.g. `-20`) |
| `color_missing.cub` | Missing floor or ceiling line |
| `color_missing_ceiling_rgb.cub` | Ceiling RGB incomplete |
| `color_missing_floor_rgb.cub` | Floor RGB incomplete |
| `color_none.cub` | No `F` or `C` line at all |
| `empty.cub` | Completely empty file |
| `file_letter_end.cub` | Extra character appended after valid content |
| `filetype_missing` | No `.cub` extension |
| `filetype_wrong.buc` | Wrong extension (`.buc`) |
| `map_first.cub` | Map appears before the header |
| `map_middle.cub` | Map appears in the middle of the header |
| `map_missing.cub` | Header present but no map grid |
| `map_only.cub` | Map with no header |
| `map_too_small.cub` | Map grid too small to be valid |
| `player_multiple.cub` | More than one player start position |
| `player_none.cub` | No player start position |
| `player_on_edge.cub` | Player placed on a wall boundary |
| `test_map_to_big.cub` | Map grid exceeds size limits |
| `textures_dir.cub` | Texture path points to a directory |
| `textures_duplicates.cub` | Same identifier declared twice |
| `textures_forbidden.cub` | Texture file does not exist |
| `textures_invalid.cub` | Texture path is invalid / too short |
| `textures_missing.cub` | One or more texture identifiers absent |
| `textures_none.cub` | No texture lines at all |
| `textures_not_xpm.cub` | Texture file missing `.xpm` extension |
| `wall_hole_east.cub` | East wall has a gap |
| `wall_hole_north.cub` | North wall has a gap |
| `wall_hole_south.cub` | South wall has a gap |
| `wall_hole_west.cub` | West wall has a gap |
| `wall_none.cub` | Map contains no walls |

---

## Screenshot

![cub3D running with a good map](.picture/Capture%20d'%C3%A9cran%202026-02-27%20%C3%A0%2012.55.24.png)

---

## Notes

- Texture paths in all map files are relative to the **cub3D project root** (the directory
  containing the `cub3D` binary), not to `tester_cub3D/` itself.
  They follow the pattern: `tester_cub3D/data/texture/<name>.xpm`
- The test script uses a `0.4 s` timeout: a map is considered "running" if the process is still
  alive after that delay. Adjust `TIMEOUT` in `test_maps.sh` if needed.
- Maps in `map/good/` are designed to be parseable and renderable; they do **not** test for
  correct raycasting output — only that the program does not crash or exit early.
