/**
 * Conway's Game of Life — Java
 *
 * Grid:  60 x 30 (toroidal — edges wrap)
 * Alive = '#'   Dead = ' '
 * Press Ctrl+C to quit.
 */

import java.util.Random;

public class GameOfLife {

    static final int ROWS = 30;
    static final int COLS = 60;
    static final double DENSITY = 0.30;
    static final int DELAY_MS = 100;

    private int[][] grid = new int[ROWS][COLS];

    public GameOfLife() {
        Random rng = new Random();
        for (int r = 0; r < ROWS; r++)
            for (int c = 0; c < COLS; c++)
                grid[r][c] = rng.nextDouble() < DENSITY ? 1 : 0;
    }

    private int countNeighbours(int r, int c) {
        int count = 0;
        for (int dr = -1; dr <= 1; dr++)
            for (int dc = -1; dc <= 1; dc++) {
                if (dr == 0 && dc == 0) continue;
                int nr = (r + dr + ROWS) % ROWS;
                int nc = (c + dc + COLS) % COLS;
                count += grid[nr][nc];
            }
        return count;
    }

    private void nextGeneration() {
        int[][] next = new int[ROWS][COLS];
        for (int r = 0; r < ROWS; r++)
            for (int c = 0; c < COLS; c++) {
                int n = countNeighbours(r, c);
                if (grid[r][c] == 1)
                    next[r][c] = (n == 2 || n == 3) ? 1 : 0;
                else
                    next[r][c] = (n == 3) ? 1 : 0;
            }
        grid = next;
    }

    private void display(int generation) {
        int alive = 0;
        for (int[] row : grid)
            for (int cell : row)
                alive += cell;

        StringBuilder sb = new StringBuilder();
        sb.append("\033[2J\033[H");
        sb.append("Generation ").append(generation)
          .append("  |  Alive: ").append(alive).append('\n');

        // Top border
        sb.append('+');
        sb.append("-".repeat(COLS));
        sb.append("+\n");

        // Grid
        for (int r = 0; r < ROWS; r++) {
            sb.append('|');
            for (int c = 0; c < COLS; c++)
                sb.append(grid[r][c] == 1 ? '#' : ' ');
            sb.append("|\n");
        }

        // Bottom border
        sb.append('+');
        sb.append("-".repeat(COLS));
        sb.append("+\n");

        sb.append("Press Ctrl+C to quit.\n");
        System.out.print(sb);
        System.out.flush();
    }

    public void run() throws InterruptedException {
        for (int gen = 0; ; gen++) {
            display(gen);
            nextGeneration();
            Thread.sleep(DELAY_MS);
        }
    }

    public static void main(String[] args) throws InterruptedException {
        new GameOfLife().run();
    }
}
