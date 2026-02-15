/* ================================================================
 * Conway's Game of Life — C
 *
 * Grid:  60 x 30 (toroidal — edges wrap)
 * Alive = '#'   Dead = ' '
 * Press Ctrl+C to quit.
 * ================================================================ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#define ROWS 30
#define COLS 60
#define DELAY_US 100000 /* 100 ms */
#define DENSITY 0.30

static int grid[ROWS][COLS];
static int next[ROWS][COLS];

static void seed_grid(void)
{
    srand((unsigned)time(NULL));
    for (int r = 0; r < ROWS; r++)
        for (int c = 0; c < COLS; c++)
            grid[r][c] = ((double)rand() / RAND_MAX) < DENSITY ? 1 : 0;
}

static int count_neighbours(int r, int c)
{
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

static void next_generation(void)
{
    for (int r = 0; r < ROWS; r++)
        for (int c = 0; c < COLS; c++) {
            int n = count_neighbours(r, c);
            if (grid[r][c])
                next[r][c] = (n == 2 || n == 3) ? 1 : 0;
            else
                next[r][c] = (n == 3) ? 1 : 0;
        }
    memcpy(grid, next, sizeof(grid));
}

static void display(int generation)
{
    int alive = 0;
    for (int r = 0; r < ROWS; r++)
        for (int c = 0; c < COLS; c++)
            alive += grid[r][c];

    /* Clear screen */
    printf("\033[2J\033[H");

    printf("Generation %d  |  Alive: %d\n", generation, alive);

    /* Top border */
    putchar('+');
    for (int c = 0; c < COLS; c++) putchar('-');
    puts("+");

    /* Grid */
    for (int r = 0; r < ROWS; r++) {
        putchar('|');
        for (int c = 0; c < COLS; c++)
            putchar(grid[r][c] ? '#' : ' ');
        puts("|");
    }

    /* Bottom border */
    putchar('+');
    for (int c = 0; c < COLS; c++) putchar('-');
    puts("+");

    puts("Press Ctrl+C to quit.");
}

int main(void)
{
    seed_grid();
    for (int gen = 0; ; gen++) {
        display(gen);
        next_generation();
        usleep(DELAY_US);
    }
    return 0;
}
