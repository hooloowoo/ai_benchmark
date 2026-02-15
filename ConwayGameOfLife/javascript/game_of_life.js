/**
 * Conway's Game of Life — JavaScript (Node.js)
 *
 * Grid:  60 x 30 (toroidal — edges wrap)
 * Alive = '#'   Dead = ' '
 * Press Ctrl+C to quit.
 */

const ROWS = 30;
const COLS = 60;
const DENSITY = 0.30;
const DELAY_MS = 100;

function makeGrid() {
    return Array.from({ length: ROWS }, () =>
        Array.from({ length: COLS }, () => (Math.random() < DENSITY ? 1 : 0))
    );
}

function countNeighbours(grid, r, c) {
    let count = 0;
    for (let dr = -1; dr <= 1; dr++) {
        for (let dc = -1; dc <= 1; dc++) {
            if (dr === 0 && dc === 0) continue;
            const nr = (r + dr + ROWS) % ROWS;
            const nc = (c + dc + COLS) % COLS;
            count += grid[nr][nc];
        }
    }
    return count;
}

function nextGeneration(grid) {
    return grid.map((row, r) =>
        row.map((cell, c) => {
            const n = countNeighbours(grid, r, c);
            if (cell) return (n === 2 || n === 3) ? 1 : 0;
            return n === 3 ? 1 : 0;
        })
    );
}

function display(grid, generation) {
    let alive = 0;
    for (const row of grid) for (const cell of row) alive += cell;

    const lines = [];
    lines.push('\x1B[2J\x1B[H');
    lines.push(`Generation ${generation}  |  Alive: ${alive}`);

    const border = '+' + '-'.repeat(COLS) + '+';
    lines.push(border);

    for (const row of grid) {
        lines.push('|' + row.map(c => (c ? '#' : ' ')).join('') + '|');
    }

    lines.push(border);
    lines.push('Press Ctrl+C to quit.');
    process.stdout.write(lines.join('\n') + '\n');
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    let grid = makeGrid();
    let gen = 0;
    while (true) {
        display(grid, gen);
        grid = nextGeneration(grid);
        gen++;
        await sleep(DELAY_MS);
    }
}

main();
