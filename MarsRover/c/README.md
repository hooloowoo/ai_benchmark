# Mars Rover — C

A terminal-based tunnel-running game in C11. Steer a rover through a randomly curving tunnel without hitting the walls.

## Features

- 60×25 scrolling tunnel with random curves
- Raw terminal input (non-blocking)
- Score display on status line
- Smooth frame timing via `usleep`

## Requirements

### macOS

- Xcode Command Line Tools
  ```bash
  xcode-select --install
  ```

### Linux (Debian/Ubuntu)

- GCC
  ```bash
  sudo apt install gcc
  ```

### Windows

- [MinGW-w64](https://www.mingw-w64.org/) or [MSYS2](https://www.msys2.org/)
  ```powershell
  choco install mingw
  ```
- Note: The raw terminal code uses POSIX `termios`; on Windows, compile under MSYS2/Cygwin or adapt to use `conio.h`.

## Compile

```bash
gcc -o mars_rover mars_rover.c -std=c11
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
