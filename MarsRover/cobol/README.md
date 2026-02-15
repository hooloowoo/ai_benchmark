# Mars Rover — COBOL

A terminal-based tunnel-running game in GnuCOBOL (free format). Steer a rover through a randomly curving tunnel without hitting the walls.

## Features

- 60×25 scrolling tunnel with random curves
- Timed `ACCEPT` for non-blocking keyboard input
- Score tracking with status line
- ANSI escape code rendering

## Requirements

### macOS

- GnuCOBOL
  ```bash
  brew install gnucobol
  ```

### Linux (Debian/Ubuntu)

- GnuCOBOL
  ```bash
  sudo apt install gnucobol
  ```

### Windows

- Download GnuCOBOL from [https://gnucobol.sourceforge.io/](https://gnucobol.sourceforge.io/)
- Or use [Arnold COBOL Compiler](https://sourceforge.net/projects/open-cobol/)

Alternatively, using [Chocolatey](https://chocolatey.org/):
```powershell
choco install gnucobol
```

## Compile

```bash
cobc -x -free -o mars_rover mars_rover.cob
```

## Run

```bash
./mars_rover
```

## Controls

| Key       | Action     |
|-----------|------------|
| A         | Move left  |
| D         | Move right |
| Q         | Quit       |
