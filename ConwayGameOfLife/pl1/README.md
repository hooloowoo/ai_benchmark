# Conway's Game of Life — PL/I

A terminal-based implementation of Conway's Game of Life in PL/I.

## Features

- 60×30 toroidal grid (edges wrap around)
- Random initial pattern (~30% density)
- Status line showing generation count and alive cell count
- ANSI terminal clear for smooth animation

## Requirements

### Iron Spring PL/I (Linux/macOS)

Download from [http://www.iron-spring.com/](http://www.iron-spring.com/)

### PL/I for GCC (pli-gcc)

Available on some Linux distributions:

```bash
sudo apt install pli      # if available
```

### IBM Enterprise PL/I (z/OS / Windows)

Available as part of IBM's compiler suite for mainframe or Windows development.

### Micro Focus Open PL/I (Windows/Linux)

Commercial compiler — [https://www.microfocus.com/](https://www.microfocus.com/)

## Compile

Example with Iron Spring PL/I:

```bash
pli -o game_of_life game_of_life.pl1
```

Example with pli-gcc:

```bash
pli-gcc game_of_life.pl1 -o game_of_life
```

## Run

```bash
./game_of_life
```

## Controls

| Key    | Action |
|--------|--------|
| Ctrl+C | Quit   |

## Notes

PL/I compiler availability varies by platform. The source uses standard PL/I features (`RANDOM()`, `MOD()`, `SUBSTR()`, `PUT EDIT`) and should be compatible with most PL/I compilers. The ANSI escape sequences for screen clearing may need adjustment on non-Unix terminals.
