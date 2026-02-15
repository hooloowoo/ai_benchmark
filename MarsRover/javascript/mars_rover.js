/**
 * Mars Rover — JavaScript (Node.js)
 *
 * Tunnel-running game. Rover at the bottom, tunnel scrolls down.
 * Steer left/right to avoid walls.
 */

const WIDTH    = 60;
const HEIGHT   = 25;
const TUNNEL_W = 14;
const DELAY_MS = 70;

let tunnel = [];
let roverX = Math.floor(WIDTH / 2);
const roverRow = HEIGHT - 2;
let score = 0;
let alive = true;

// Init tunnel
let left = Math.floor((WIDTH - TUNNEL_W) / 2);
for (let i = 0; i < HEIGHT; i++) {
    tunnel.push(left);
    left += Math.floor(Math.random() * 3) - 1;
    left = Math.max(1, Math.min(WIDTH - TUNNEL_W - 1, left));
}

// Raw mode for keyboard input
process.stdin.setRawMode(true);
process.stdin.resume();
process.stdin.setEncoding('utf8');

process.stdin.on('data', (key) => {
    if (key === 'q' || key === 'Q' || key === '\u0003') {
        alive = false;
        return;
    }
    if (key === '\u001b[D' || key === 'a' || key === 'A') { // left
        if (roverX > 0) roverX--;
    }
    if (key === '\u001b[C' || key === 'd' || key === 'D') { // right
        if (roverX < WIDTH - 1) roverX++;
    }
});

function scrollTunnel() {
    // New row at top, scrolls toward rover
    tunnel.pop();
    let drift = Math.floor(Math.random() * 5) - 2;
    let nl = tunnel[0] + drift;
    nl = Math.max(1, Math.min(WIDTH - TUNNEL_W - 1, nl));
    tunnel.unshift(nl);
}

function render() {
    const lines = ['\x1B[2J\x1B[H'];
    lines.push(`  MARS ROVER  |  Score: ${score}`);
    for (let r = 0; r < HEIGHT; r++) {
        const tl = tunnel[r];
        const tr = tl + TUNNEL_W;
        let row = '';
        for (let c = 0; c < WIDTH; c++) {
            if (r === roverRow && c === roverX) row += 'A';
            else if (c <= tl || c >= tr) row += '#';
            else row += ' ';
        }
        lines.push(row);
    }
    lines.push('  Arrow keys / A,D to steer  |  Q to quit');
    process.stdout.write(lines.join('\n') + '\n');
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function main() {
    while (alive) {
        scrollTunnel();
        score++;

        // Collision
        const tl = tunnel[roverRow];
        const tr = tl + TUNNEL_W;
        if (roverX <= tl || roverX >= tr) {
            alive = false;
        }

        render();
        if (!alive) break;
        await sleep(DELAY_MS);
    }

    process.stdout.write(`\x1B[2J\x1B[H\n  GAME OVER!  Final Score: ${score}\n\n`);
    process.stdin.setRawMode(false);
    process.exit(0);
}

main();
