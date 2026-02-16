/**
 * Mars Rover — Prolog (SWI-Prolog)
 *
 * Tunnel-running game. Rover at the bottom, tunnel scrolls down.
 * Steer left/right to avoid walls.
 *
 * Run:  swipl mars_rover.pl
 */

:- use_module(library(random)).
:- use_module(library(lists)).

/* ── Constants ─────────────────────────────────────────────── */

width(60).
height(25).
tunnel_w(14).
delay_ms(70).
rover_row(Row) :- height(H), Row is H - 2.

/* ── Terminal helpers ──────────────────────────────────────── */

clear_screen :-
    format("\e[2J\e[H", []).

set_raw_mode :-
    shell("stty -icanon -echo min 0 < /dev/tty", _).

restore_terminal :-
    shell("stty sane < /dev/tty", _).

/* Sleep for N milliseconds */
sleep_ms(Ms) :-
    S is Ms / 1000.0,
    sleep(S).

/* ── Tunnel generation ─────────────────────────────────────── */

% clamp(+Value, +Min, +Max, -Clamped)
clamp(V, Min, Max, C) :-
    C is max(Min, min(Max, V)).

% initial_tunnel(-Tunnel) — list of left-edge positions, top-to-bottom
initial_tunnel(Tunnel) :-
    width(W), tunnel_w(TW), height(H),
    Left0 is (W - TW) // 2,
    length(Tunnel, H),
    fill_tunnel(Tunnel, Left0, W, TW).

fill_tunnel([], _, _, _).
fill_tunnel([Left|Rest], Prev, W, TW) :-
    random_between(-1, 1, Drift),
    L0 is Prev + Drift,
    MaxLeft is W - TW - 1,
    clamp(L0, 1, MaxLeft, Left),
    fill_tunnel(Rest, Left, W, TW).

% scroll_tunnel(+OldTunnel, -NewTunnel)
%   Shift rows down (drop last, prepend new top row).
scroll_tunnel(Old, [NewLeft|Trimmed]) :-
    width(W), tunnel_w(TW),
    append(Trimmed, [_], Old),
    Old = [TopLeft|_],
    random_between(-2, 2, Drift),
    L0 is TopLeft + Drift,
    MaxLeft is W - TW - 1,
    clamp(L0, 1, MaxLeft, NewLeft).

/* ── Rendering ─────────────────────────────────────────────── */

render(Tunnel, RoverX, Score) :-
    clear_screen,
    format("  MARS ROVER  |  Score: ~d~n", [Score]),
    rover_row(RRow),
    render_rows(Tunnel, 0, RRow, RoverX),
    format("  A/D keys to steer  |  Q to quit~n", []).

render_rows([], _, _, _).
render_rows([Left|Rest], Row, RRow, RoverX) :-
    width(W), tunnel_w(TW),
    Right is Left + TW,
    render_row_cols(0, W, Row, RRow, RoverX, Left, Right),
    nl,
    Row1 is Row + 1,
    render_rows(Rest, Row1, RRow, RoverX).

render_row_cols(Col, W, _, _, _, _, _) :-
    Col >= W, !.
render_row_cols(Col, W, Row, RRow, RoverX, Left, Right) :-
    (   Row =:= RRow, Col =:= RoverX
    ->  put_char('A')
    ;   (Col =< Left ; Col >= Right)
    ->  put_char('#')
    ;   put_char(' ')
    ),
    Col1 is Col + 1,
    render_row_cols(Col1, W, Row, RRow, RoverX, Left, Right).

/* ── Collision detection ───────────────────────────────────── */

check_collision(Tunnel, RoverX) :-
    rover_row(RRow),
    nth0(RRow, Tunnel, Left),
    tunnel_w(TW),
    Right is Left + TW,
    (RoverX =< Left ; RoverX >= Right).

/* ── Non-blocking input ────────────────────────────────────── */

% Try to read a character; unify with none if nothing available.
read_key(Key) :-
    (   peek_char(user_input, _)
    ->  get_char(user_input, Ch),
        process_key(Ch, Key)
    ;   Key = none
    ).

process_key('q', quit) :- !.
process_key('Q', quit) :- !.
process_key('a', left) :- !.
process_key('A', left) :- !.
process_key('d', right) :- !.
process_key('D', right) :- !.
process_key('\e', Key) :- !,
    (   peek_char(user_input, _)
    ->  get_char(user_input, '['),
        get_char(user_input, Arrow),
        (   Arrow = 'D' -> Key = left
        ;   Arrow = 'C' -> Key = right
        ;   Key = none
        )
    ;   Key = none
    ).
process_key(_, none).

/* Drain all pending input, keep last meaningful key */
drain_input(FinalKey) :-
    drain_input_acc(none, FinalKey).

drain_input_acc(Acc, Final) :-
    read_key(K),
    (   K = none
    ->  Final = Acc
    ;   (K = quit -> Final = quit
        ; (K \= none -> drain_input_acc(K, Final)
          ; drain_input_acc(Acc, Final)))
    ).

/* ── Apply movement ────────────────────────────────────────── */

apply_key(left, RX0, RX) :-
    !, RX is max(0, RX0 - 1).
apply_key(right, RX0, RX) :-
    !, width(W), RX is min(W - 1, RX0 + 1).
apply_key(_, RX, RX).

/* ── Game loop ─────────────────────────────────────────────── */

game_loop(Tunnel, RoverX, Score) :-
    drain_input(Key),
    (   Key = quit
    ->  game_over(Score)
    ;   apply_key(Key, RoverX, RoverX1),
        scroll_tunnel(Tunnel, Tunnel1),
        Score1 is Score + 1,
        (   check_collision(Tunnel1, RoverX1)
        ->  render(Tunnel1, RoverX1, Score1),
            game_over(Score1)
        ;   render(Tunnel1, RoverX1, Score1),
            delay_ms(D), sleep_ms(D),
            game_loop(Tunnel1, RoverX1, Score1)
        )
    ).

game_over(Score) :-
    clear_screen,
    format("~n  GAME OVER!  Final Score: ~d~n~n", [Score]).

/* ── Entry point ───────────────────────────────────────────── */

main :-
    set_raw_mode,
    initial_tunnel(Tunnel),
    width(W),
    RoverX is W // 2,
    render(Tunnel, RoverX, 0),
    delay_ms(D), sleep_ms(D),
    catch(
        game_loop(Tunnel, RoverX, 0),
        _Error,
        true
    ),
    restore_terminal.

:- initialization(main, main).
