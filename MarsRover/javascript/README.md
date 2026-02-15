# Mars Rover — JavaScript (Node.js)

A terminal-based tunnel-running game in JavaScript. Steer a rover through a randomly curving tunnel without hitting the walls.

## Features

- 60×25 scrolling tunnel with random curves
- Non-blocking raw stdin input
- Async/await game loop
- Score tracking with status line

## Requirements

### macOS

- Node.js 16+
  ```bash
  brew install node
  ```

### Linux (Debian/Ubuntu)

- Node.js 16+
  ```bash
  sudo apt install nodejs
  ```

### Windows

- Download Node.js from [https://nodejs.org/](https://nodejs.org/) and install it

## Run

```bash
node mars_rover.js
```

No compilation step is needed.

## Controls

| Key       | Action     |
|-----------|------------|
| A         | Move left  |
| D         | Move right |
| Q         | Quit       |
