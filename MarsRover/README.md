# Mars Rover

A collection of tunnel-running games in several programming languages and platforms. Steer a rover through a randomly curving tunnel — survive as long as you can!

## About the Game

You pilot a Mars rover speeding through a narrow, winding tunnel carved into the Martian surface. The tunnel scrolls upward and randomly shifts left or right each frame. Hit a wall and it's game over. Your score increases the longer you survive.

## Implementations

| Language | Directory | Screen Size | Notes |
|----------|-----------|-------------|-------|
| [Python](python/) | `python/` | 60×25 | Terminal, non-blocking input via select/termios |
| [C](c/) | `c/` | 60×25 | C11, raw terminal via termios |
| [C++](cpp/) | `cpp/` | 60×25 | C++17, mt19937 RNG, buffered rendering |
| [Java](java/) | `java/` | 60×25 | Raw mode via stty, System.in.available() |
| [JavaScript](javascript/) | `javascript/` | 60×25 | Node.js, raw stdin, async/await |
| [COBOL](cobol/) | `cobol/` | 60×25 | GnuCOBOL, ACCEPT WITH TIMEOUT |
| [C64 Assembly](c64/) | `c64/` | 40×25 | 6502/6510 ASM (ACME), joystick + keyboard |
| [PL/I](pl1/) | `pl1/` | 60×25 | Standard PL/I (no free compiler widely available) |
| [Prolog](prolog/) | `prolog/` | 60×25 | SWI-Prolog, non-blocking input via stty raw mode |

## Quick Start

Each subdirectory has its own `README.md` with platform-specific requirements (macOS, Linux, Windows), compilation instructions, and controls.

### Example — Python (no dependencies)

```bash
cd python
python mars_rover.py
```

### Example — C++

```bash
cd cpp
g++ -o mars_rover mars_rover.cpp -std=c++17
./mars_rover
```

### Example — C64

```bash
cd c64
acme -f cbm -o mars_rover.prg mars_rover.asm
x64sc mars_rover.prg
```

## Controls

All terminal implementations share the same controls:

| Key       | Action     |
|-----------|------------|
| A / ←    | Move left  |
| D / →    | Move right |
| Q         | Quit       |

The C64 version also supports joystick port 2.
