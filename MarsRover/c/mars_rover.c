/* ================================================================
 * Mars Rover — C
 *
 * Tunnel-running game. Rover at the bottom, tunnel scrolls down.
 * Steer left/right to avoid walls.
 * ================================================================ */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <termios.h>
#include <sys/select.h>

#define WIDTH        60
#define HEIGHT       25
#define TUNNEL_W     14
#define ROVER_CHAR   'A'
#define WALL_CHAR    '#'
#define DELAY_US     70000

static int tunnel[HEIGHT]; /* left-wall position for each row */

static int kbhit(void)
{
    struct timeval tv = {0, 0};
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(0, &fds);
    return select(1, &fds, NULL, NULL, &tv) > 0;
}

static int getch(void)
{
    unsigned char c;
    if (read(0, &c, 1) == 1) return c;
    return -1;
}

static void init_tunnel(void)
{
    int left = (WIDTH - TUNNEL_W) / 2;
    for (int i = 0; i < HEIGHT; i++) {
        tunnel[i] = left;
        int drift = (rand() % 3) - 1; /* -1, 0, +1 */
        left += drift;
        if (left < 1) left = 1;
        if (left > WIDTH - TUNNEL_W - 1) left = WIDTH - TUNNEL_W - 1;
    }
}

static void scroll_tunnel(void)
{
    /* Shift rows down; new row appears at top */
    memmove(tunnel + 1, tunnel, (HEIGHT - 1) * sizeof(int));
    int drift = (rand() % 5) - 2; /* -2..+2 */
    int left = tunnel[1] + drift;
    if (left < 1) left = 1;
    if (left > WIDTH - TUNNEL_W - 1) left = WIDTH - TUNNEL_W - 1;
    tunnel[0] = left;
}

static void render(int rover_x, int score, int rover_row)
{
    printf("\033[2J\033[H");
    printf("  MARS ROVER  |  Score: %d\n", score);
    for (int r = 0; r < HEIGHT; r++) {
        int tl = tunnel[r];
        int tr = tl + TUNNEL_W;
        for (int c = 0; c < WIDTH; c++) {
            if (r == rover_row && c == rover_x)
                putchar(ROVER_CHAR);
            else if (c <= tl || c >= tr)
                putchar(WALL_CHAR);
            else
                putchar(' ');
        }
        putchar('\n');
    }
    printf("  Arrow keys to steer  |  Q to quit\n");
    fflush(stdout);
}

int main(void)
{
    struct termios oldt, newt;
    tcgetattr(0, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(0, TCSANOW, &newt);

    srand((unsigned)time(NULL));
    init_tunnel();

    int rover_x = WIDTH / 2;
    int rover_row = HEIGHT - 2;
    int score = 0;
    int alive = 1;

    while (alive) {
        /* Input */
        while (kbhit()) {
            int ch = getch();
            if (ch == 'q' || ch == 'Q') { alive = 0; break; }
            if (ch == 27) { /* escape sequence */
                if (kbhit() && getch() == '[') {
                    int k = getch();
                    if (k == 'D' && rover_x > 0) rover_x--;
                    if (k == 'C' && rover_x < WIDTH - 1) rover_x++;
                }
            }
            if ((ch == 'a' || ch == 'A') && rover_x > 0) rover_x--;
            if ((ch == 'd' || ch == 'D') && rover_x < WIDTH - 1) rover_x++;
        }
        if (!alive) break;

        scroll_tunnel();
        score++;

        /* Collision */
        int tl = tunnel[rover_row];
        int tr = tl + TUNNEL_W;
        if (rover_x <= tl || rover_x >= tr) alive = 0;

        render(rover_x, score, rover_row);
        usleep(DELAY_US);
    }

    printf("\033[2J\033[H\n  GAME OVER!  Final Score: %d\n\n", score);
    tcsetattr(0, TCSANOW, &oldt);
    return 0;
}
