# Conway's Game of Life — Commodore 64

A 6502/6510 assembly implementation of Conway's Game of Life for the Commodore 64, using the full 40×24 text screen with a status line.

![Game of Life running on C64](Screenshot%202026-02-15%20at%2020.01.56.png)

## Features

- 40×24 toroidal grid (edges wrap around)
- Random initial pattern seeded via SID noise
- Status line showing generation count and alive cell count
- Pause/resume with SPACE, quit with Q
- Original C64 color scheme (light blue border, dark blue background, white cells)

## Requirements

### macOS

- [ACME](https://sourceforge.net/projects/acme-crossass/) cross-assembler
  ```bash
  brew install acme
  ```
- [VICE](https://vice-emu.sourceforge.io/) emulator (optional, for running)
  ```bash
  brew install --cask vice
  ```

### Linux (Debian/Ubuntu)

- ACME cross-assembler
  ```bash
  sudo apt install acme
  ```
- VICE emulator (optional, for running)
  ```bash
  sudo apt install vice
  ```

### Windows

- Download ACME from [https://sourceforge.net/projects/acme-crossass/](https://sourceforge.net/projects/acme-crossass/) and add it to your PATH
- Download VICE from [https://vice-emu.sourceforge.io/](https://vice-emu.sourceforge.io/) and install it

Alternatively, using [Chocolatey](https://chocolatey.org/):
```powershell
choco install vice
```

## Compile

```bash
acme -f cbm -o game_of_life.prg game_of_life.asm
```

## Run

### In VICE emulator

```bash
x64sc game_of_life.prg
```

### On real hardware

1. Transfer `game_of_life.prg` to a disk image or SD card
2. `LOAD "GAME_OF_LIFE",8,1`
3. `RUN`

## Controls

| Key   | Action         |
|-------|----------------|
| SPACE | Pause / Resume |
| Q     | Quit           |
