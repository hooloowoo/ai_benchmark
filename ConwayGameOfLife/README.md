# Conway's Game of Life

A collection of [Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life) implementations in several programming languages and platforms.

## About the Game

Conway's Game of Life is a zero-player cellular automaton devised by mathematician John Conway in 1970. A grid of cells evolves through generations based on simple rules:

1. **Underpopulation** — A live cell with fewer than 2 live neighbours dies.
2. **Survival** — A live cell with 2 or 3 live neighbours survives.
3. **Overpopulation** — A live cell with more than 3 live neighbours dies.
4. **Reproduction** — A dead cell with exactly 3 live neighbours becomes alive.

All implementations use a toroidal grid (edges wrap around) and start from a random initial state.

## Implementations

| Language | Directory | Grid Size | Notes |
|----------|-----------|-----------|-------|
| [Python](python/) | `python/` | 60×30 | Terminal, configurable via CLI args |
| [C](c/) | `c/` | 60×30 | C11, ANSI terminal |
| [C++](cpp/) | `cpp/` | 60×30 | C++17, buffered rendering |
| [Java](java/) | `java/` | 60×30 | StringBuilder buffered output |
| [JavaScript](javascript/) | `javascript/` | 60×30 | Node.js, async/await loop |
| [COBOL](cobol/) | `cobol/` | 60×30 | GnuCOBOL, free format |
| [C64 Assembly](c64/) | `c64/` | 40×24 | 6502/6510 ASM (ACME), runs on VICE or real hardware |
| [PL/I](pl1/) | `pl1/` | 60×30 | Standard PL/I (no free compiler widely available) |
| [Prolog](prolog/) | `prolog/` | 60×30 | SWI-Prolog, toroidal grid with findall-based generation |

## Quick Start

Each subdirectory has its own `README.md` with platform-specific requirements (macOS, Linux, Windows), compilation instructions, and controls.

### Example — Python (no dependencies)

```bash
cd python
python game_of_life.py
```

### Example — C

```bash
cd c
gcc -o game_of_life game_of_life.c -std=c11
./game_of_life
```

### Example — C64

```bash
cd c64
acme -f cbm -o game_of_life.prg game_of_life.asm
x64sc game_of_life.prg
```

## Screenshots

<p>
  <img src="c64/Screenshot%202026-02-15%20at%2020.01.56.png" alt="Game of Life on C64" width="480">
  <img src="python/Screenshot%202026-02-15%20at%2019.53.38.png" alt="Game of Life in terminal" width="480">
</p>
