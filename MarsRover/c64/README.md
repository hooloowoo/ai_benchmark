# Mars Rover — Commodore 64

A 6502/6510 assembly implementation of a tunnel-running game for the Commodore 64. Navigate a rover through a scrolling, randomly curving tunnel.

## Features

- 40×25 text-screen tunnel with smooth scrolling
- Joystick port 2 or keyboard (A/D) steering
- SID noise-based random tunnel generation
- Score display, GAME OVER screen
- Original C64 color scheme

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
acme -f cbm -o mars_rover.prg mars_rover.asm
```

## Run

### In VICE emulator

```bash
x64sc mars_rover.prg
```

### On real hardware

1. Transfer `mars_rover.prg` to a disk image or SD card
2. `LOAD "MARS ROVER",8,1`
3. `RUN`

## Controls

| Input              | Action     |
|--------------------|------------|
| Joystick Left      | Move left  |
| Joystick Right     | Move right |
| A                  | Move left  |
| D                  | Move right |
| Q                  | Quit       |
