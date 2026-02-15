# Conway's Game of Life — JavaScript (Node.js)

A terminal-based implementation of Conway's Game of Life in JavaScript, running on Node.js.

## Features

- 60×30 toroidal grid (edges wrap around)
- Random initial pattern
- Status line showing generation count and alive cell count
- Async/await loop with configurable delay

## Requirements

### macOS

```bash
brew install node
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install nodejs
```

### Windows

Download from [https://nodejs.org/](https://nodejs.org/) or use Chocolatey:

```powershell
choco install nodejs
```

## Run

No compilation needed:

```bash
node game_of_life.js
```

## Controls

| Key    | Action |
|--------|--------|
| Ctrl+C | Quit   |
