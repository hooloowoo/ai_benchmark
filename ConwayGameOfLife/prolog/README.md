# Conway's Game of Life — Prolog

A terminal-based implementation of Conway's Game of Life in Prolog (SWI-Prolog).

## Features

- 60×30 toroidal grid (edges wrap around)
- Box-drawing border with live stats (generation count, alive cells)
- Random initial state with configurable density

## Requirements

- [SWI-Prolog](https://www.swi-prolog.org/) 8.0+

### Install SWI-Prolog

**macOS (Homebrew):**

```bash
brew install swi-prolog
```

**Ubuntu / Debian:**

```bash
sudo apt install swi-prolog
```

**Windows:**

Download the installer from https://www.swi-prolog.org/download/stable

## Run

```bash
swipl game_of_life.pl
```

## Controls

| Key     | Action |
|---------|--------|
| Ctrl+C  | Quit   |
