# Conway's Game of Life — COBOL

A terminal-based implementation of Conway's Game of Life in COBOL (GnuCOBOL).

## Features

- 60×30 toroidal grid (edges wrap around)
- Random initial pattern seeded from system time
- Status line showing generation count and alive cell count
- Box-drawing border
- ANSI terminal clear for smooth animation

## Requirements

### macOS

```bash
brew install gnucobol
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install gnucobol
```

### Windows

Download GnuCOBOL from [https://gnucobol.sourceforge.io/](https://gnucobol.sourceforge.io/) or use [MSYS2](https://www.msys2.org/):

```bash
pacman -S mingw-w64-x86_64-gnucobol
```

## Compile

```bash
cobc -x -free -o game_of_life game_of_life.cob
```

## Run

```bash
./game_of_life
```

## Controls

| Key    | Action |
|--------|--------|
| Ctrl+C | Quit   |
