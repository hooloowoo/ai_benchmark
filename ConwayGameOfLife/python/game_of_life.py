"""Conway's Game of Life — terminal edition."""

import os
import time
import random
import sys

# ── Configuration ────────────────────────────────────────────────────
ROWS = 30
COLS = 60
ALIVE = "█"
DEAD = " "
DELAY = 0.1  # seconds between generations


def random_grid(rows: int, cols: int, density: float = 0.3) -> list[list[int]]:
    """Return a grid seeded randomly with the given alive-cell density."""
    return [
        [1 if random.random() < density else 0 for _ in range(cols)]
        for _ in range(rows)
    ]


def count_neighbors(grid: list[list[int]], r: int, c: int) -> int:
    """Count the eight neighbours of cell (r, c), wrapping at edges."""
    rows, cols = len(grid), len(grid[0])
    total = 0
    for dr in (-1, 0, 1):
        for dc in (-1, 0, 1):
            if dr == 0 and dc == 0:
                continue
            total += grid[(r + dr) % rows][(c + dc) % cols]
    return total


def next_generation(grid: list[list[int]]) -> list[list[int]]:
    """Compute the next generation according to the classic rules.

    1. Any live cell with 2 or 3 neighbours survives.
    2. Any dead cell with exactly 3 neighbours becomes alive.
    3. All other cells die or stay dead.
    """
    rows, cols = len(grid), len(grid[0])
    new = [[0] * cols for _ in range(rows)]
    for r in range(rows):
        for c in range(cols):
            n = count_neighbors(grid, r, c)
            if grid[r][c] == 1:
                new[r][c] = 1 if n in (2, 3) else 0
            else:
                new[r][c] = 1 if n == 3 else 0
    return new


def render(grid: list[list[int]], generation: int) -> str:
    """Return a string representation of the grid."""
    lines = [f"Generation {generation}  |  Alive: {sum(sum(row) for row in grid)}"]
    lines.append("┌" + "─" * len(grid[0]) + "┐")
    for row in grid:
        lines.append("│" + "".join(ALIVE if cell else DEAD for cell in row) + "│")
    lines.append("└" + "─" * len(grid[0]) + "┘")
    lines.append("Press Ctrl+C to quit.")
    return "\n".join(lines)


def clear_screen() -> None:
    os.system("cls" if os.name == "nt" else "clear")


def main() -> None:
    rows = ROWS
    cols = COLS
    density = 0.3

    # Allow optional CLI overrides: rows cols density
    if len(sys.argv) >= 3:
        rows, cols = int(sys.argv[1]), int(sys.argv[2])
    if len(sys.argv) >= 4:
        density = float(sys.argv[3])

    grid = random_grid(rows, cols, density)
    generation = 0

    try:
        while True:
            clear_screen()
            print(render(grid, generation))
            grid = next_generation(grid)
            generation += 1
            time.sleep(DELAY)
    except KeyboardInterrupt:
        print(f"\nStopped after {generation} generations.")


if __name__ == "__main__":
    main()
