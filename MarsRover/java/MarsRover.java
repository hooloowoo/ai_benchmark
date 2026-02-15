/**
 * Mars Rover — Java
 *
 * Tunnel-running game. Rover at the bottom, tunnel scrolls down.
 * Steer left/right to avoid walls.
 */

import java.io.IOException;
import java.util.Random;

public class MarsRover {

    static final int WIDTH     = 60;
    static final int HEIGHT    = 25;
    static final int TUNNEL_W  = 14;
    static final int DELAY_MS  = 70;

    private int[] tunnel = new int[HEIGHT];
    private int roverX;
    private int roverRow = HEIGHT - 2;
    private int score = 0;
    private Random rng = new Random();

    public MarsRover() {
        roverX = WIDTH / 2;
        int left = (WIDTH - TUNNEL_W) / 2;
        for (int i = 0; i < HEIGHT; i++) {
            tunnel[i] = left;
            left += rng.nextInt(3) - 1;
            left = Math.max(1, Math.min(WIDTH - TUNNEL_W - 1, left));
        }
    }

    private void scrollTunnel() {
        /* Shift rows down; new row appears at top */
        System.arraycopy(tunnel, 0, tunnel, 1, HEIGHT - 1);
        int drift = rng.nextInt(5) - 2;
        int left = tunnel[1] + drift;
        left = Math.max(1, Math.min(WIDTH - TUNNEL_W - 1, left));
        tunnel[0] = left;
    }

    private void render() {
        StringBuilder sb = new StringBuilder();
        sb.append("\033[2J\033[H");
        sb.append("  MARS ROVER  |  Score: ").append(score).append('\n');
        for (int r = 0; r < HEIGHT; r++) {
            int tl = tunnel[r];
            int tr = tl + TUNNEL_W;
            for (int c = 0; c < WIDTH; c++) {
                if (r == roverRow && c == roverX) sb.append('A');
                else if (c <= tl || c >= tr) sb.append('#');
                else sb.append(' ');
            }
            sb.append('\n');
        }
        sb.append("  A/D keys to steer  |  Q to quit\n");
        System.out.print(sb);
        System.out.flush();
    }

    private boolean checkCollision() {
        int tl = tunnel[roverRow];
        int tr = tl + TUNNEL_W;
        return roverX <= tl || roverX >= tr;
    }

    public void run() throws IOException, InterruptedException {
        // Set terminal to raw mode via stty
        String[] cmd = {"/bin/sh", "-c", "stty -icanon -echo min 0 < /dev/tty"};
        Runtime.getRuntime().exec(cmd).waitFor();

        try {
            boolean alive = true;
            while (alive) {
                // Input
                while (System.in.available() > 0) {
                    int ch = System.in.read();
                    if (ch == 'q' || ch == 'Q') { alive = false; break; }
                    if (ch == 27) { // escape
                        if (System.in.available() > 0 && System.in.read() == '[') {
                            if (System.in.available() > 0) {
                                int k = System.in.read();
                                if (k == 'D' && roverX > 0) roverX--;
                                if (k == 'C' && roverX < WIDTH - 1) roverX++;
                            }
                        }
                    }
                    if ((ch == 'a' || ch == 'A') && roverX > 0) roverX--;
                    if ((ch == 'd' || ch == 'D') && roverX < WIDTH - 1) roverX++;
                }
                if (!alive) break;

                scrollTunnel();
                score++;

                if (checkCollision()) alive = false;

                render();
                Thread.sleep(DELAY_MS);
            }

            System.out.print("\033[2J\033[H\n  GAME OVER!  Final Score: " + score + "\n\n");
        } finally {
            String[] restore = {"/bin/sh", "-c", "stty sane < /dev/tty"};
            Runtime.getRuntime().exec(restore).waitFor();
        }
    }

    public static void main(String[] args) throws Exception {
        new MarsRover().run();
    }
}
