# Conway's Game of Life — C++

A terminal-based implementation of Conway's Game of Life in C++17.

## Features

- 60×30 toroidal grid (edges wrap around)
- Random initial pattern (using `<random>` Mersenne Twister)
- Status line showing generation count and alive cell count
- Buffered output for flicker-free rendering

## Requirements

### macOS

```bash
xcode-select --install   # provides g++/clang++
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install g++
```

### Windows

Install [MinGW-w64](https://www.mingw-w64.org/) or use MSYS2:

```powershell
pacman -S mingw-w64-x86_64-gcc
```

## Compile

```bash
g++ -o game_of_life game_of_life.cpp -std=c++17
```

## Run

```bash
./game_of_life
```

## Controls

| Key    | Action |
|--------|--------|
| Ctrl+C | Quit   |
