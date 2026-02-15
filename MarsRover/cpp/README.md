# Mars Rover — C++

A terminal-based tunnel-running game in C++17. Steer a rover through a randomly curving tunnel without hitting the walls.

## Features

- 60×25 scrolling tunnel with random curves
- Raw terminal input (non-blocking)
- Mersenne Twister RNG for smooth tunnel generation
- Buffered output via `ostringstream` for flicker-free rendering

## Requirements

### macOS

- Xcode Command Line Tools
  ```bash
  xcode-select --install
  ```

### Linux (Debian/Ubuntu)

- G++
  ```bash
  sudo apt install g++
  ```

### Windows

- [MinGW-w64](https://www.mingw-w64.org/) or [MSYS2](https://www.msys2.org/)
  ```powershell
  choco install mingw
  ```
- Note: The raw terminal code uses POSIX `termios`; on Windows, compile under MSYS2/Cygwin or adapt to use Windows console API.

## Compile

```bash
g++ -o mars_rover mars_rover.cpp -std=c++17
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
