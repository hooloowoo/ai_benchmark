# Conway's Game of Life — Java

A terminal-based implementation of Conway's Game of Life in Java.

## Features

- 60×30 toroidal grid (edges wrap around)
- Random initial pattern
- Status line showing generation count and alive cell count
- Buffered `StringBuilder` output for smooth rendering

## Requirements

### macOS

```bash
brew install openjdk
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install default-jdk
```

### Windows

Download from [https://adoptium.net/](https://adoptium.net/) or use Chocolatey:

```powershell
choco install temurin
```

## Compile

```bash
javac GameOfLife.java
```

## Run

```bash
java GameOfLife
```

## Controls

| Key    | Action |
|--------|--------|
| Ctrl+C | Quit   |
