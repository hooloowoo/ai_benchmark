/**
 * Conway's Game of Life — Prolog (SWI-Prolog)
 *
 * Grid:  60 x 30 (toroidal — edges wrap)
 * Alive = '#'   Dead = ' '
 * Press Ctrl+C to quit.
 *
 * Run:  swipl game_of_life.pl
 */

:- use_module(library(random)).
:- use_module(library(lists)).

/* ── Constants ─────────────────────────────────────────────── */

rows(30).
cols(60).
density(0.30).
delay_ms(100).

/* ── Terminal helpers ──────────────────────────────────────── */

clear_screen :-
    format("\e[2J\e[H", []).

sleep_ms(Ms) :-
    S is Ms / 1000.0,
    sleep(S).

/* ── Grid representation ───────────────────────────────────── */
%
% The grid is a list of ROWS lists, each of COLS length.
% 1 = alive, 0 = dead.

% random_grid(-Grid)
random_grid(Grid) :-
    rows(R), cols(C),
    length(Grid, R),
    maplist(random_row(C), Grid).

random_row(Cols, Row) :-
    length(Row, Cols),
    maplist(random_cell, Row).

random_cell(Cell) :-
    density(D),
    random(X),
    (X < D -> Cell = 1 ; Cell = 0).

/* ── Cell access with toroidal wrap ────────────────────────── */

% get_cell(+Grid, +R, +C, -Value)
get_cell(Grid, R, C, Value) :-
    rows(NR), cols(NC),
    WR is ((R mod NR) + NR) mod NR,
    WC is ((C mod NC) + NC) mod NC,
    nth0(WR, Grid, Row),
    nth0(WC, Row, Value).

/* ── Neighbour counting ────────────────────────────────────── */

count_neighbours(Grid, R, C, Count) :-
    R1 is R - 1, R2 is R + 1,
    C1 is C - 1, C2 is C + 1,
    get_cell(Grid, R1, C1, V1),
    get_cell(Grid, R1, C,  V2),
    get_cell(Grid, R1, C2, V3),
    get_cell(Grid, R,  C1, V4),
    get_cell(Grid, R,  C2, V5),
    get_cell(Grid, R2, C1, V6),
    get_cell(Grid, R2, C,  V7),
    get_cell(Grid, R2, C2, V8),
    Count is V1+V2+V3+V4+V5+V6+V7+V8.

/* ── Next generation ───────────────────────────────────────── */

% next_cell(+Grid, +R, +C, -NewVal)
next_cell(Grid, R, C, NewVal) :-
    get_cell(Grid, R, C, Cur),
    count_neighbours(Grid, R, C, N),
    (   Cur =:= 1
    ->  ((N =:= 2 ; N =:= 3) -> NewVal = 1 ; NewVal = 0)
    ;   (N =:= 3 -> NewVal = 1 ; NewVal = 0)
    ).

% next_generation(+Grid, -NextGrid)
next_generation(Grid, NextGrid) :-
    rows(NR), cols(NC),
    MaxR is NR - 1,
    MaxC is NC - 1,
    findall(Row,
        (   between(0, MaxR, R),
            findall(Cell,
                (   between(0, MaxC, C),
                    next_cell(Grid, R, C, Cell)
                ),
                Row)
        ),
        NextGrid).

/* ── Counting alive cells ──────────────────────────────────── */

count_alive(Grid, Alive) :-
    flatten(Grid, Flat),
    include(=:=(1), Flat, LiveCells),
    length(LiveCells, Alive).

/* ── Display ───────────────────────────────────────────────── */

display_grid(Grid, Gen) :-
    clear_screen,
    count_alive(Grid, Alive),
    format("Generation ~d  |  Alive: ~d~n", [Gen, Alive]),

    % Top border
    cols(C),
    put_char('+'),
    print_n_chars(C, '-'),
    format("+~n", []),

    % Grid rows
    maplist(display_row, Grid),

    % Bottom border
    put_char('+'),
    print_n_chars(C, '-'),
    format("+~n", []),

    format("Press Ctrl+C to quit.~n", []),
    flush_output.

display_row(Row) :-
    put_char('|'),
    maplist(display_cell, Row),
    format("|~n", []).

display_cell(1) :- put_char('#').
display_cell(0) :- put_char(' ').

print_n_chars(0, _) :- !.
print_n_chars(N, Ch) :-
    N > 0,
    put_char(Ch),
    N1 is N - 1,
    print_n_chars(N1, Ch).

/* ── Game loop ─────────────────────────────────────────────── */

game_loop(Grid, Gen) :-
    display_grid(Grid, Gen),
    next_generation(Grid, NextGrid),
    delay_ms(D), sleep_ms(D),
    Gen1 is Gen + 1,
    game_loop(NextGrid, Gen1).

/* ── Entry point ───────────────────────────────────────────── */

main :-
    random_grid(Grid),
    catch(
        game_loop(Grid, 0),
        _Error,
        true
    ).

:- initialization(main, main).
