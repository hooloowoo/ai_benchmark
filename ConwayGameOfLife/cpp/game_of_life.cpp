// ================================================================
// Conway's Game of Life — C++
//
// Grid:  60 x 30 (toroidal — edges wrap)
// Alive = '#'   Dead = ' '
// Press Ctrl+C to quit.
// ================================================================

#include <iostream>
#include <vector>
#include <random>
#include <chrono>
#include <thread>
#include <sstream>

constexpr int ROWS = 30;
constexpr int COLS = 60;
constexpr double DENSITY = 0.30;
constexpr int DELAY_MS = 100;

using Grid = std::vector<std::vector<int>>;

Grid make_grid() {
    std::mt19937 rng(static_cast<unsigned>(
        std::chrono::steady_clock::now().time_since_epoch().count()));
    std::uniform_real_distribution<double> dist(0.0, 1.0);

    Grid g(ROWS, std::vector<int>(COLS, 0));
    for (int r = 0; r < ROWS; ++r)
        for (int c = 0; c < COLS; ++c)
            g[r][c] = dist(rng) < DENSITY ? 1 : 0;
    return g;
}

int count_neighbours(const Grid& g, int r, int c) {
    int count = 0;
    for (int dr = -1; dr <= 1; ++dr)
        for (int dc = -1; dc <= 1; ++dc) {
            if (dr == 0 && dc == 0) continue;
            int nr = (r + dr + ROWS) % ROWS;
            int nc = (c + dc + COLS) % COLS;
            count += g[nr][nc];
        }
    return count;
}

Grid next_generation(const Grid& g) {
    Grid ng(ROWS, std::vector<int>(COLS, 0));
    for (int r = 0; r < ROWS; ++r)
        for (int c = 0; c < COLS; ++c) {
            int n = count_neighbours(g, r, c);
            if (g[r][c])
                ng[r][c] = (n == 2 || n == 3) ? 1 : 0;
            else
                ng[r][c] = (n == 3) ? 1 : 0;
        }
    return ng;
}

void display(const Grid& g, int generation) {
    int alive = 0;
    for (auto& row : g)
        for (auto cell : row)
            alive += cell;

    std::ostringstream out;
    out << "\033[2J\033[H";
    out << "Generation " << generation << "  |  Alive: " << alive << "\n";

    // Top border
    out << '+';
    for (int c = 0; c < COLS; ++c) out << '-';
    out << "+\n";

    // Grid
    for (int r = 0; r < ROWS; ++r) {
        out << '|';
        for (int c = 0; c < COLS; ++c)
            out << (g[r][c] ? '#' : ' ');
        out << "|\n";
    }

    // Bottom border
    out << '+';
    for (int c = 0; c < COLS; ++c) out << '-';
    out << "+\n";

    out << "Press Ctrl+C to quit.\n";
    std::cout << out.str() << std::flush;
}

int main() {
    auto grid = make_grid();
    for (int gen = 0; ; ++gen) {
        display(grid, gen);
        grid = next_generation(grid);
        std::this_thread::sleep_for(std::chrono::milliseconds(DELAY_MS));
    }
    return 0;
}
