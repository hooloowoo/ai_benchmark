# Conway's Game of Life — C

A terminal-based implementation of Conway's Game of Life in C.

## Features

- 60×30 toroidal grid (edges wrap around)
- Random initial pattern
- Status line showing generation count and alive cell count
- ANSI terminal clear for smooth animation

## Requirements

### macOS

```bash
xcode-select --install   # provides gcc/clang
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install gcc
```

### Windows

Install [MinGW-w64](https://www.mingw-w64.org/) or use MSYS2:

```powershell
pacman -S mingw-w64-x86_64-gcc
```

## Compile

```bash
gcc -o game_of_life game_of_life.c -std=c11
```

## Run

```bash
./game_of_life
```

## Controls

| Key    | Action |
|--------|--------|
| Ctrl+C | Quit   |
