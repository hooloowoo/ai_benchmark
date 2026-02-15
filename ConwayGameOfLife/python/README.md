# Conway's Game of Life — Python

A terminal-based implementation of Conway's Game of Life in Python.

![Game of Life running in terminal](Screenshot%202026-02-15%20at%2019.53.38.png)

## Features

- 60×30 toroidal grid (edges wrap around) — configurable via CLI args
- Box-drawing border with live stats (generation count, alive cells)
- Adjustable simulation speed and initial density

## Requirements

- Python 3.10+

No external dependencies are needed.

## Run

```bash
python game_of_life.py
```

### Optional arguments

```bash
python game_of_life.py [rows] [cols] [density]
```

| Argument  | Default | Description                          |
|-----------|---------|--------------------------------------|
| `rows`    | 30      | Number of grid rows                  |
| `cols`    | 60      | Number of grid columns               |
| `density` | 0.3     | Initial probability of a cell being alive (0.0–1.0) |

Example — small grid with high density:

```bash
python game_of_life.py 20 40 0.5
```

## Controls

| Key     | Action |
|---------|--------|
| Ctrl+C  | Quit   |
