# Mars Rover — PL/I

A terminal-based tunnel-running game in PL/I. Steer a rover through a randomly curving tunnel without hitting the walls.

## Features

- 60×25 scrolling tunnel with random curves
- PUT EDIT-based screen rendering
- Score tracking with status line
- Frame delay via loop-based timing

## Requirements

There is no widely available free PL/I compiler for all platforms. Options include:

### IBM Mainframe

- Enterprise PL/I for z/OS (IBM)
- Use JCL to compile: `EXEC IBMZPLI`

### Linux

- [Iron Spring PL/I](http://www.iron-spring.com/) (commercial, x86 Linux)
- [PL/I for GCC](https://github.com/nicholasgasior/plgcc) (experimental)

### Windows

- [Micro Focus Open PL/I](https://www.microfocus.com/) (commercial)

### Online

- [Rexx.info PL/I](https://www.rexx.info/) — web-based interpreters may support a subset

## Compile (example with Iron Spring PL/I)

```bash
pli mars_rover.pl1 -o mars_rover
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
