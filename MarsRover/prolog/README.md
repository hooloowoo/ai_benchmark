# Mars Rover — Prolog

A terminal-based tunnel-running game in Prolog (SWI-Prolog). Steer a rover through a randomly curving tunnel without hitting the walls.

## Features

- 60×25 scrolling tunnel with random curves
- Non-blocking keyboard input (arrow keys or A/D)
- Score counter increases as you survive
- ANSI terminal rendering with clear-screen

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
swipl mars_rover.pl
```

## Controls

| Key            | Action     |
|----------------|------------|
| ← / A         | Move left  |
| → / D         | Move right |
| Q              | Quit       |
