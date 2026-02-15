       IDENTIFICATION DIVISION.
       PROGRAM-ID. MARS-ROVER.
       AUTHOR. MARS.

      *> ============================================================
      *> Mars Rover — COBOL
      *>
      *> Tunnel-running game. Rover at the bottom, tunnel scrolls.
      *> A/D to steer, Q to quit.
      *> ============================================================

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01 WS-WIDTH          PIC 99  VALUE 60.
       01 WS-HEIGHT         PIC 99  VALUE 25.
       01 WS-TUNNEL-W       PIC 99  VALUE 14.

      *> Tunnel left-wall positions (one per row)
       01 WS-TUNNEL.
          05 WS-TLEFT       PIC 99  OCCURS 25 TIMES.

      *> Game state
       01 WS-ROVER-X        PIC 99  VALUE 30.
       01 WS-ROVER-ROW      PIC 99  VALUE 23.
       01 WS-SCORE          PIC 9(5) VALUE 0.
       01 WS-ALIVE          PIC 9   VALUE 1.

      *> Working variables
       01 WS-R              PIC 99  VALUE 0.
       01 WS-C              PIC 99  VALUE 0.
       01 WS-LEFT           PIC 99  VALUE 0.
       01 WS-RIGHT          PIC 99  VALUE 0.
       01 WS-DRIFT          PIC S99 VALUE 0.
       01 WS-NEW-LEFT       PIC S999 VALUE 0.
       01 WS-RAND           PIC V9(8) VALUE 0.
       01 WS-SEED           PIC 9(8) VALUE 0.
       01 WS-I              PIC 9(4) VALUE 0.
       01 WS-KEY            PIC X   VALUE SPACE.

      *> Display
       01 WS-LINE           PIC X(62) VALUE SPACES.
       01 WS-BORDER         PIC X(62) VALUE SPACES.

       PROCEDURE DIVISION.
       MAIN-PROGRAM.
           PERFORM INIT-GAME
           PERFORM GAME-LOOP UNTIL WS-ALIVE = 0
           DISPLAY X"1B" "[2J" X"1B" "[H" WITH NO ADVANCING
           DISPLAY " "
           DISPLAY "  GAME OVER!  Final Score: " WS-SCORE
           DISPLAY " "
           STOP RUN.

      *> ============================================================
       INIT-GAME.
           ACCEPT WS-SEED FROM TIME
           MOVE FUNCTION RANDOM(WS-SEED) TO WS-RAND

      *>   Build border
           MOVE SPACES TO WS-BORDER
           STRING "+" DELIMITED SIZE INTO WS-BORDER
           PERFORM VARYING WS-I FROM 1 BY 1
               UNTIL WS-I > WS-WIDTH
               STRING WS-BORDER DELIMITED SPACES
                      "-" DELIMITED SIZE INTO WS-BORDER
           END-PERFORM
           STRING WS-BORDER DELIMITED SPACES
                  "+" DELIMITED SIZE INTO WS-BORDER

      *>   Init tunnel centred
           COMPUTE WS-LEFT =
               (WS-WIDTH - WS-TUNNEL-W) / 2
           PERFORM VARYING WS-R FROM 1 BY 1
               UNTIL WS-R > WS-HEIGHT
               MOVE WS-LEFT TO WS-TLEFT(WS-R)
               MOVE FUNCTION RANDOM TO WS-RAND
               COMPUTE WS-DRIFT =
                   FUNCTION INTEGER(WS-RAND * 3) - 1
               COMPUTE WS-NEW-LEFT = WS-LEFT + WS-DRIFT
               IF WS-NEW-LEFT < 1
                   MOVE 1 TO WS-LEFT
               ELSE IF WS-NEW-LEFT >
                   WS-WIDTH - WS-TUNNEL-W - 1
                   COMPUTE WS-LEFT =
                       WS-WIDTH - WS-TUNNEL-W - 1
               ELSE
                   MOVE WS-NEW-LEFT TO WS-LEFT
               END-IF
           END-PERFORM

           MOVE 30 TO WS-ROVER-X.

      *> ============================================================
       GAME-LOOP.
      *>   Read input (ACCEPT with timeout is not standard,
      *>   so we use ACCEPT and the user presses a key each frame)
           ACCEPT WS-KEY FROM ENVIRONMENT "COB_SCREEN_ESC"
               ON EXCEPTION MOVE SPACE TO WS-KEY
           END-ACCEPT

      *>   Simple: ACCEPT a character
           DISPLAY X"1B" "[6n" WITH NO ADVANCING
           ACCEPT WS-KEY WITH NO-ECHO TIMEOUT 1
               ON EXCEPTION MOVE SPACE TO WS-KEY
           END-ACCEPT

           EVALUATE TRUE
               WHEN WS-KEY = "a" OR WS-KEY = "A"
                   IF WS-ROVER-X > 1
                       SUBTRACT 1 FROM WS-ROVER-X
                   END-IF
               WHEN WS-KEY = "d" OR WS-KEY = "D"
                   IF WS-ROVER-X < WS-WIDTH
                       ADD 1 TO WS-ROVER-X
                   END-IF
               WHEN WS-KEY = "q" OR WS-KEY = "Q"
                   MOVE 0 TO WS-ALIVE
           END-EVALUATE

      *>   Scroll tunnel (shift down, new row at top)
           PERFORM VARYING WS-R FROM WS-HEIGHT BY -1
               UNTIL WS-R <= 1
               MOVE WS-TLEFT(WS-R - 1) TO WS-TLEFT(WS-R)
           END-PERFORM

      *>   New top row
           MOVE FUNCTION RANDOM TO WS-RAND
           COMPUTE WS-DRIFT =
               FUNCTION INTEGER(WS-RAND * 5) - 2
           COMPUTE WS-NEW-LEFT =
               WS-TLEFT(2) + WS-DRIFT
           IF WS-NEW-LEFT < 1
               MOVE 1 TO WS-NEW-LEFT
           END-IF
           IF WS-NEW-LEFT > WS-WIDTH - WS-TUNNEL-W - 1
               COMPUTE WS-NEW-LEFT =
                   WS-WIDTH - WS-TUNNEL-W - 1
           END-IF
           MOVE WS-NEW-LEFT TO WS-TLEFT(1)

      *>   Collision check
           MOVE WS-TLEFT(WS-ROVER-ROW) TO WS-LEFT
           COMPUTE WS-RIGHT = WS-LEFT + WS-TUNNEL-W
           IF WS-ROVER-X <= WS-LEFT OR
              WS-ROVER-X >= WS-RIGHT
               MOVE 0 TO WS-ALIVE
           END-IF

           ADD 1 TO WS-SCORE

      *>   Render
           DISPLAY X"1B" "[2J" X"1B" "[H" WITH NO ADVANCING
           DISPLAY "  MARS ROVER  |  Score: " WS-SCORE

           DISPLAY WS-BORDER

           PERFORM VARYING WS-R FROM 1 BY 1
               UNTIL WS-R > WS-HEIGHT
               MOVE SPACES TO WS-LINE
               MOVE "|" TO WS-LINE(1:1)
               MOVE WS-TLEFT(WS-R) TO WS-LEFT
               COMPUTE WS-RIGHT = WS-LEFT + WS-TUNNEL-W
               PERFORM VARYING WS-C FROM 1 BY 1
                   UNTIL WS-C > WS-WIDTH
                   IF WS-R = WS-ROVER-ROW AND
                      WS-C = WS-ROVER-X
                       MOVE "A" TO WS-LINE(WS-C + 1 : 1)
                   ELSE IF WS-C <= WS-LEFT OR
                           WS-C >= WS-RIGHT
                       MOVE "#" TO WS-LINE(WS-C + 1 : 1)
                   ELSE
                       MOVE " " TO WS-LINE(WS-C + 1 : 1)
                   END-IF
               END-PERFORM
               MOVE "|" TO WS-LINE(WS-WIDTH + 2 : 1)
               DISPLAY WS-LINE
           END-PERFORM

           DISPLAY WS-BORDER
           DISPLAY "  A/D to steer  |  Q to quit".
