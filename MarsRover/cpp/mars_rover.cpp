// ================================================================
// Mars Rover — C++
//
// Tunnel-running game. Rover at the bottom, tunnel scrolls down.
// Steer left/right to avoid walls.
// ================================================================

#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <thread>
#include <sstream>
#include <termios.h>
#include <unistd.h>
#include <sys/select.h>

constexpr int WIDTH      = 60;
constexpr int HEIGHT     = 25;
constexpr int TUNNEL_W   = 14;
constexpr int DELAY_MS   = 70;
constexpr char ROVER     = 'A';
constexpr char WALL      = '#';

static bool kbhit() {
    timeval tv{0, 0};
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(0, &fds);
    return select(1, &fds, nullptr, nullptr, &tv) > 0;
}

static int getch_nb() {
    unsigned char c;
    if (read(0, &c, 1) == 1) return c;
    return -1;
}

int main() {
    // Raw terminal
    termios oldt{}, newt{};
    tcgetattr(0, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(0, TCSANOW, &newt);

    std::mt19937 rng(static_cast<unsigned>(
        std::chrono::steady_clock::now().time_since_epoch().count()));
    std::uniform_int_distribution<int> drift_dist(-1, 1);
    std::uniform_int_distribution<int> drift_dist2(-2, 2);

    // Init tunnel
    std::vector<int> tunnel(HEIGHT);
    int left = (WIDTH - TUNNEL_W) / 2;
    for (int i = 0; i < HEIGHT; ++i) {
        tunnel[i] = left;
        left += drift_dist(rng);
        left = std::max(1, std::min(WIDTH - TUNNEL_W - 1, left));
    }

    int rover_x = WIDTH / 2;
    int rover_row = HEIGHT - 2;
    int score = 0;
    bool alive = true;

    while (alive) {
        // Input
        while (kbhit()) {
            int ch = getch_nb();
            if (ch == 'q' || ch == 'Q') { alive = false; break; }
            if (ch == 27) {
                if (kbhit() && getch_nb() == '[') {
                    int k = getch_nb();
                    if (k == 'D' && rover_x > 0) --rover_x;
                    if (k == 'C' && rover_x < WIDTH - 1) ++rover_x;
                }
            }
            if ((ch == 'a' || ch == 'A') && rover_x > 0) --rover_x;
            if ((ch == 'd' || ch == 'D') && rover_x < WIDTH - 1) ++rover_x;
        }
        if (!alive) break;

        // Scroll
        tunnel.erase(tunnel.begin());
        left = tunnel.back() + drift_dist2(rng);
        left = std::max(1, std::min(WIDTH - TUNNEL_W - 1, left));
        tunnel.push_back(left);
        ++score;

        // Collision
        int tl = tunnel[rover_row];
        int tr = tl + TUNNEL_W;
        if (rover_x <= tl || rover_x >= tr) alive = false;

        // Render
        std::ostringstream out;
        out << "\033[2J\033[H";
        out << "  MARS ROVER  |  Score: " << score << "\n";
        for (int r = 0; r < HEIGHT; ++r) {
            tl = tunnel[r];
            tr = tl + TUNNEL_W;
            for (int c = 0; c < WIDTH; ++c) {
                if (r == rover_row && c == rover_x) out << ROVER;
                else if (c <= tl || c >= tr) out << WALL;
                else out << ' ';
            }
            out << '\n';
        }
        out << "  Arrow keys to steer  |  Q to quit\n";
        std::cout << out.str() << std::flush;

        std::this_thread::sleep_for(std::chrono::milliseconds(DELAY_MS));
    }

    std::cout << "\033[2J\033[H\n  GAME OVER!  Final Score: " << score << "\n\n";
    tcsetattr(0, TCSANOW, &oldt);
    return 0;
}
