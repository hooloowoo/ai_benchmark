       IDENTIFICATION DIVISION.
       PROGRAM-ID. GAME-OF-LIFE.
       AUTHOR. CONWAY.

      *> ============================================================
      *> Conway's Game of Life — COBOL
      *>
      *> Grid:  60 x 30 (toroidal — edges wrap)
      *> Alive = '#'   Dead = ' '
      *> Press Ctrl+C to quit.
      *> ============================================================

       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *> Grid dimensions
       01 WS-ROWS          PIC 99  VALUE 30.
       01 WS-COLS          PIC 99  VALUE 60.

      *> Current and next-generation grids (1 = alive, 0 = dead)
       01 WS-GRID.
          05 WS-GRID-ROW   OCCURS 30 TIMES.
             10 WS-CELL    PIC 9   OCCURS 60 TIMES.

       01 WS-NEXT.
          05 WS-NEXT-ROW   OCCURS 30 TIMES.
             10 WS-NCELL   PIC 9   OCCURS 60 TIMES.

      *> Loop counters and working variables
       01 WS-R             PIC 99  VALUE 0.
       01 WS-C             PIC 99  VALUE 0.
       01 WS-DR            PIC S99 VALUE 0.
       01 WS-DC            PIC S99 VALUE 0.
       01 WS-NR            PIC S999 VALUE 0.
       01 WS-NC            PIC S999 VALUE 0.
       01 WS-WRAP-R        PIC 99  VALUE 0.
       01 WS-WRAP-C        PIC 99  VALUE 0.
       01 WS-NEIGHBOURS    PIC 99  VALUE 0.

      *> Generation counter and alive count
       01 WS-GENERATION    PIC 9(5) VALUE 0.
       01 WS-ALIVE         PIC 9(4) VALUE 0.

      *> Display line buffer
       01 WS-LINE          PIC X(62) VALUE SPACES.
       01 WS-STATUS        PIC X(40) VALUE SPACES.

      *> Random number work fields
       01 WS-RAND          PIC V9(8) VALUE 0.
       01 WS-SEED          PIC 9(8)  VALUE 0.
       01 WS-I             PIC 9(4)  VALUE 0.

      *> Border line
       01 WS-BORDER-TOP    PIC X(62) VALUE SPACES.
       01 WS-BORDER-BOT    PIC X(62) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
           PERFORM INIT-BORDERS
           PERFORM SEED-GRID
           PERFORM GAME-LOOP UNTIL 1 = 0
           STOP RUN.

      *> ============================================================
      *> Build border strings
      *> ============================================================
       INIT-BORDERS.
           MOVE SPACES TO WS-BORDER-TOP
           MOVE SPACES TO WS-BORDER-BOT
           STRING
               "+" DELIMITED SIZE
               INTO WS-BORDER-TOP
           END-STRING
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-COLS
               STRING
                   WS-BORDER-TOP DELIMITED SPACES
                   "-"           DELIMITED SIZE
                   INTO WS-BORDER-TOP
               END-STRING
           END-PERFORM
           STRING
               WS-BORDER-TOP DELIMITED SPACES
               "+"            DELIMITED SIZE
               INTO WS-BORDER-TOP
           END-STRING
           MOVE WS-BORDER-TOP TO WS-BORDER-BOT.

      *> ============================================================
      *> Seed grid with random alive/dead cells
      *> ============================================================
       SEED-GRID.
           ACCEPT WS-SEED FROM TIME
           MOVE FUNCTION RANDOM(WS-SEED) TO WS-RAND
           PERFORM VARYING WS-R FROM 1 BY 1
               UNTIL WS-R > WS-ROWS
               PERFORM VARYING WS-C FROM 1 BY 1
                   UNTIL WS-C > WS-COLS
                   MOVE FUNCTION RANDOM TO WS-RAND
                   IF WS-RAND < 0.30
                       MOVE 1 TO WS-CELL(WS-R, WS-C)
                   ELSE
                       MOVE 0 TO WS-CELL(WS-R, WS-C)
                   END-IF
               END-PERFORM
           END-PERFORM.

      *> ============================================================
      *> Main game loop — one iteration per generation
      *> ============================================================
       GAME-LOOP.
           PERFORM DISPLAY-GRID
           PERFORM COMPUTE-NEXT-GEN
           PERFORM COPY-NEXT-TO-CURRENT
           ADD 1 TO WS-GENERATION.

      *> ============================================================
      *> Display the grid to the terminal
      *> ============================================================
       DISPLAY-GRID.
      *>   Clear screen (ANSI escape)
           DISPLAY X"1B" "[2J" X"1B" "[H"
               WITH NO ADVANCING

      *>   Count alive cells
           MOVE 0 TO WS-ALIVE
           PERFORM VARYING WS-R FROM 1 BY 1
               UNTIL WS-R > WS-ROWS
               PERFORM VARYING WS-C FROM 1 BY 1
                   UNTIL WS-C > WS-COLS
                   IF WS-CELL(WS-R, WS-C) = 1
                       ADD 1 TO WS-ALIVE
                   END-IF
               END-PERFORM
           END-PERFORM

      *>   Status line
           STRING
               "Generation " DELIMITED SIZE
               WS-GENERATION  DELIMITED SIZE
               "  |  Alive: " DELIMITED SIZE
               WS-ALIVE       DELIMITED SIZE
               INTO WS-STATUS
           END-STRING
           DISPLAY WS-STATUS

      *>   Top border
           DISPLAY WS-BORDER-TOP

      *>   Grid rows
           PERFORM VARYING WS-R FROM 1 BY 1
               UNTIL WS-R > WS-ROWS
               MOVE SPACES TO WS-LINE
               MOVE "|" TO WS-LINE(1:1)
               PERFORM VARYING WS-C FROM 1 BY 1
                   UNTIL WS-C > WS-COLS
                   IF WS-CELL(WS-R, WS-C) = 1
                       MOVE "#" TO WS-LINE(WS-C + 1 : 1)
                   ELSE
                       MOVE " " TO WS-LINE(WS-C + 1 : 1)
                   END-IF
               END-PERFORM
               MOVE "|" TO WS-LINE(WS-COLS + 2 : 1)
               DISPLAY WS-LINE
           END-PERFORM

      *>   Bottom border
           DISPLAY WS-BORDER-BOT
           DISPLAY "Press Ctrl+C to quit.".

      *> ============================================================
      *> Compute next generation into WS-NEXT
      *> ============================================================
       COMPUTE-NEXT-GEN.
           PERFORM VARYING WS-R FROM 1 BY 1
               UNTIL WS-R > WS-ROWS
               PERFORM VARYING WS-C FROM 1 BY 1
                   UNTIL WS-C > WS-COLS
                   PERFORM COUNT-NEIGHBOURS
                   IF WS-CELL(WS-R, WS-C) = 1
      *>               Alive: survive with 2 or 3
                       IF WS-NEIGHBOURS = 2 OR
                          WS-NEIGHBOURS = 3
                           MOVE 1 TO WS-NCELL(WS-R, WS-C)
                       ELSE
                           MOVE 0 TO WS-NCELL(WS-R, WS-C)
                       END-IF
                   ELSE
      *>               Dead: born with exactly 3
                       IF WS-NEIGHBOURS = 3
                           MOVE 1 TO WS-NCELL(WS-R, WS-C)
                       ELSE
                           MOVE 0 TO WS-NCELL(WS-R, WS-C)
                       END-IF
                   END-IF
               END-PERFORM
           END-PERFORM.

      *> ============================================================
      *> Count the 8 neighbours of cell (WS-R, WS-C) with wrapping
      *> ============================================================
       COUNT-NEIGHBOURS.
           MOVE 0 TO WS-NEIGHBOURS
           PERFORM VARYING WS-DR FROM -1 BY 1
               UNTIL WS-DR > 1
               PERFORM VARYING WS-DC FROM -1 BY 1
                   UNTIL WS-DC > 1
                   IF WS-DR = 0 AND WS-DC = 0
                       CONTINUE
                   ELSE
      *>               Toroidal wrapping
                       COMPUTE WS-NR = WS-R + WS-DR
                       COMPUTE WS-NC = WS-C + WS-DC
                       IF WS-NR < 1
                           COMPUTE WS-WRAP-R = WS-NR + WS-ROWS
                       ELSE IF WS-NR > WS-ROWS
                           COMPUTE WS-WRAP-R = WS-NR - WS-ROWS
                       ELSE
                           MOVE WS-NR TO WS-WRAP-R
                       END-IF
                       IF WS-NC < 1
                           COMPUTE WS-WRAP-C = WS-NC + WS-COLS
                       ELSE IF WS-NC > WS-COLS
                           COMPUTE WS-WRAP-C = WS-NC - WS-COLS
                       ELSE
                           MOVE WS-NC TO WS-WRAP-C
                       END-IF
                       ADD WS-CELL(WS-WRAP-R, WS-WRAP-C)
                           TO WS-NEIGHBOURS
                   END-IF
               END-PERFORM
           END-PERFORM.

      *> ============================================================
      *> Copy next generation back to current
      *> ============================================================
       COPY-NEXT-TO-CURRENT.
           MOVE WS-NEXT TO WS-GRID.
