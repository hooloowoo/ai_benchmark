"""Mars Rover — terminal tunnel game.

A rover sits at the bottom-centre of the screen.
A tunnel with random curves scrolls downward.
Steer left/right to avoid the walls.
"""

import sys
import os
import time
import random
import tty
import termios
import select

# ── Configuration ────────────────────────────────────────────────────
WIDTH = 60
HEIGHT = 25
TUNNEL_WIDTH = 14
ROVER_CHAR = "A"
WALL_CHAR = "█"
EMPTY_CHAR = " "
DELAY = 0.07  # seconds between frames


def init_tunnel(width, tunnel_w):
    """Return initial left-wall position centred on the screen."""
    return (width - tunnel_w) // 2


def get_key():
    """Non-blocking key read (Unix)."""
    if select.select([sys.stdin], [], [], 0)[0]:
        return sys.stdin.read(1)
    return None


def clear_screen():
    sys.stdout.write("\033[2J\033[H")


def main():
    rows = HEIGHT
    cols = WIDTH
    tunnel_w = TUNNEL_WIDTH
    left = init_tunnel(cols, tunnel_w)
    rover_x = cols // 2
    score = 0

    # Build initial tunnel map (list of left-wall positions)
    tunnel = []
    for _ in range(rows):
        tunnel.append(left)
        drift = random.choice([-1, 0, 0, 1])
        left = max(1, min(cols - tunnel_w - 1, left + drift))

    # Set terminal to raw mode for non-blocking input
    old_settings = termios.tcgetattr(sys.stdin)
    try:
        tty.setcbreak(sys.stdin.fileno())

        alive = True
        while alive:
            # ── Input ─────────────────────────────────────────────
            key = get_key()
            if key == "q" or key == "Q":
                break
            elif key in ("\x1b",):  # escape sequence
                k2 = get_key()
                if k2 == "[":
                    k3 = get_key()
                    if k3 == "D":        # left arrow
                        rover_x = max(0, rover_x - 1)
                    elif k3 == "C":      # right arrow
                        rover_x = min(cols - 1, rover_x + 1)
            elif key == "a" or key == "A":
                rover_x = max(0, rover_x - 1)
            elif key == "d" or key == "D":
                rover_x = min(cols - 1, rover_x + 1)

            # ── Scroll tunnel (new row at top, scrolls toward rover) ──
            tunnel.pop()
            drift = random.choice([-1, -1, 0, 0, 0, 1, 1])
            left = tunnel[0] + drift
            left = max(1, min(cols - tunnel_w - 1, left))
            tunnel.insert(0, left)

            # ── Collision check ───────────────────────────────────
            rover_row = rows - 2  # rover is on second-to-last row
            tl = tunnel[rover_row]
            tr = tl + tunnel_w
            if rover_x <= tl or rover_x >= tr:
                alive = False

            score += 1

            # ── Render ────────────────────────────────────────────
            buf = []
            buf.append("\033[2J\033[H")
            buf.append(f"  MARS ROVER  |  Score: {score}\n")
            for row in range(rows):
                tl = tunnel[row]
                tr = tl + tunnel_w
                line = []
                for c in range(cols):
                    if row == rover_row and c == rover_x:
                        line.append(ROVER_CHAR)
                    elif c <= tl or c >= tr:
                        line.append(WALL_CHAR)
                    else:
                        line.append(EMPTY_CHAR)
                buf.append("".join(line))
                buf.append("\n")
            buf.append("  Arrow keys / A,D to steer  |  Q to quit\n")
            sys.stdout.write("".join(buf))
            sys.stdout.flush()

            time.sleep(DELAY)

        # ── Game over ─────────────────────────────────────────────
        clear_screen()
        print(f"\n  GAME OVER!  Final Score: {score}\n")

    finally:
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)


if __name__ == "__main__":
    main()
