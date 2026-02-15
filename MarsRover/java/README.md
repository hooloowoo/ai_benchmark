# Mars Rover — Java

A terminal-based tunnel-running game in Java. Steer a rover through a randomly curving tunnel without hitting the walls.

## Features

- 60×25 scrolling tunnel with random curves
- Raw terminal input via `stty` (restores settings on exit)
- Score tracking with status line
- StringBuilder-buffered rendering

## Requirements

### macOS

- JDK 11+
  ```bash
  brew install openjdk
  ```

### Linux (Debian/Ubuntu)

- JDK 11+
  ```bash
  sudo apt install default-jdk
  ```

### Windows

- Download JDK from [https://adoptium.net/](https://adoptium.net/) and add it to your PATH
- Note: Uses `stty` for raw terminal; on Windows, run under Git Bash, WSL, or adapt to use JLine/JNI.

## Compile

```bash
javac MarsRover.java
```

## Run

```bash
java MarsRover
```

## Controls

| Key       | Action     |
|-----------|------------|
| A         | Move left  |
| D         | Move right |
| Q         | Quit       |
