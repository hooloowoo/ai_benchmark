; ============================================================================
; Mars Rover — Commodore 64
; Assembler: ACME cross-assembler
;
; Tunnel-running game on the 40x25 text screen.
; Rover 'A' at bottom-centre, tunnel scrolls down.
; Joystick port 2 or A/D keys to steer, Q to quit.
;
; Build:  acme -f cbm -o mars_rover.prg mars_rover.asm
; ============================================================================

!cpu 6510

; --- Zero-page variables ---------------------------------------------------
ZP_PTR1         = $FB
ZP_PTR1_HI      = $FC
ZP_PTR2         = $FD
ZP_PTR2_HI      = $FE
ZP_TEMP         = $02
ZP_ROW          = $03
ZP_COL          = $04
ZP_ROVER_X      = $05           ; rover column (0-39)
ZP_SCORE_LO     = $06
ZP_SCORE_HI     = $07
ZP_TUNNEL_LEFT  = $08           ; scratch: current row's left wall
ZP_DEAD         = $09           ; 0=alive, 1=dead
ZP_NUM_LO       = $0A
ZP_NUM_HI       = $0B
ZP_LEAD         = $0C
ZP_DRIFT        = $0D

; --- System addresses ------------------------------------------------------
SCREEN          = $0400
COLOR_RAM       = $D800
BORDER          = $D020
BACKGROUND      = $D021
GETIN           = $FFE4
SCNKEY          = $FF9F
CIA1_PORTA      = $DC00         ; joystick port 2
CIA1_PORTB      = $DC01

; --- Constants -------------------------------------------------------------
SCREEN_W        = 40
SCREEN_H        = 25
ROVER_ROW       = 23            ; second-to-last row
TUNNEL_W        = 12            ; tunnel width in chars
WALL_CHAR       = $A0           ; reverse space (filled block)
EMPTY_CHAR      = $20           ; space
ROVER_CHAR      = $01           ; 'A' in screen codes
STATUS_ROW      = 24            ; bottom row for score

; --- Tunnel data (left-wall position for each row, 25 bytes) ---------------
; Stored in low RAM area that won't conflict
TUNNEL          = $C000         ; 25 bytes for left-wall positions

; ============================================================================
                * = $0801

; --- BASIC stub: 10 SYS 2061 -----------------------------------------------
                !byte $0B, $08
                !byte $0A, $00
                !byte $9E
                !text "2061"
                !byte $00
                !byte $00, $00

; ============================================================================
start:
                sei

                lda #$0E                ; light blue border
                sta BORDER
                lda #$00                ; black background
                sta BACKGROUND

                ; Clear score
                lda #0
                sta ZP_SCORE_LO
                sta ZP_SCORE_HI
                sta ZP_DEAD

                ; Rover at centre
                lda #(SCREEN_W / 2)
                sta ZP_ROVER_X

                ; Init SID noise for random
                lda #$FF
                sta $D40E
                sta $D40F
                lda #$80
                sta $D412

                ; Init tunnel
                jsr init_tunnel

                ; Set colour RAM to white
                jsr set_colours

                cli

; ---- Main loop ------------------------------------------------------------
!zone main_loop
main_loop:
                jsr read_input
                lda ZP_DEAD
                bne game_over

                jsr scroll_tunnel
                jsr check_collision
                lda ZP_DEAD
                bne game_over

                ; Increment score
                inc ZP_SCORE_LO
                bne .no_carry
                inc ZP_SCORE_HI
.no_carry:
                jsr render_screen
                jsr display_status

                ; Simple delay loop
                jsr delay_frame

                jmp main_loop

game_over:
                jsr render_game_over
                jsr GETIN               ; wait for key
                beq game_over
                rts

; ============================================================================
; init_tunnel — fill tunnel array with centred tunnel
; ============================================================================
!zone init_tunnel
init_tunnel:
                lda #((SCREEN_W - TUNNEL_W) / 2)
                ldx #0
.loop:
                sta TUNNEL,x
                pha
                jsr get_random_drift
                pla
                clc
                adc ZP_DRIFT
                cmp #1
                bcs .not_low
                lda #1
.not_low:
                cmp #(SCREEN_W - TUNNEL_W - 1)
                bcc .not_high
                lda #(SCREEN_W - TUNNEL_W - 1)
.not_high:
                inx
                cpx #SCREEN_H
                bne .loop
                rts

; ============================================================================
; scroll_tunnel — shift all rows up by 1, add new row at bottom
; ============================================================================
!zone scroll_tunnel
scroll_tunnel:
                ldx #0
.shift:
                lda TUNNEL+1,x
                sta TUNNEL,x
                inx
                cpx #(SCREEN_H - 1)
                bne .shift

                ; Generate new bottom row
                lda TUNNEL+(SCREEN_H - 2)
                pha
                jsr get_random_drift
                pla
                clc
                adc ZP_DRIFT
                cmp #1
                bcs .not_low
                lda #1
.not_low:
                cmp #(SCREEN_W - TUNNEL_W - 1)
                bcc .not_high
                lda #(SCREEN_W - TUNNEL_W - 1)
.not_high:
                sta TUNNEL+(SCREEN_H - 1)
                rts

; ============================================================================
; get_random_drift — set ZP_DRIFT to -1, 0, or +1
; ============================================================================
!zone get_random_drift
get_random_drift:
                lda $D41B               ; SID random
                and #$03                ; 0-3
                cmp #0
                beq .minus
                cmp #1
                beq .zero
                cmp #2
                beq .plus
                ; 3 = zero
.zero:
                lda #0
                sta ZP_DRIFT
                rts
.minus:
                lda #$FF                ; -1
                sta ZP_DRIFT
                rts
.plus:
                lda #1
                sta ZP_DRIFT
                rts

; ============================================================================
; read_input — check keyboard for A/D/Q and joystick port 2
; ============================================================================
!zone read_input
read_input:
                jsr GETIN
                cmp #0
                beq .check_joy

                cmp #$41                ; 'A'
                beq .move_left
                cmp #$44                ; 'D'
                beq .move_right
                cmp #$51                ; 'Q'
                beq .quit
                jmp .check_joy

.move_left:
                lda ZP_ROVER_X
                beq .check_joy
                dec ZP_ROVER_X
                jmp .check_joy

.move_right:
                lda ZP_ROVER_X
                cmp #(SCREEN_W - 1)
                beq .check_joy
                inc ZP_ROVER_X
                jmp .check_joy

.quit:
                lda #1
                sta ZP_DEAD

.check_joy:
                ; Read joystick port 2 (active low)
                lda CIA1_PORTA
                lsr                     ; bit 0 = up (ignore)
                lsr                     ; bit 1 = down (ignore)
                lsr                     ; bit 2 = left
                bcs .no_joy_left
                lda ZP_ROVER_X
                beq .no_joy_left
                dec ZP_ROVER_X
.no_joy_left:
                lda CIA1_PORTA
                lsr
                lsr
                lsr
                lsr                     ; bit 3 = right
                bcs .no_joy_right
                lda ZP_ROVER_X
                cmp #(SCREEN_W - 1)
                beq .no_joy_right
                inc ZP_ROVER_X
.no_joy_right:
                rts

; ============================================================================
; check_collision — see if rover is inside a wall
; ============================================================================
!zone check_collision
check_collision:
                ldx #ROVER_ROW
                lda TUNNEL,x
                sta ZP_TUNNEL_LEFT

                ; Check left wall: rover_x <= left  means crash
                lda ZP_ROVER_X
                cmp ZP_TUNNEL_LEFT
                beq .crash
                bcc .crash

                ; Check right wall: rover_x >= left + TUNNEL_W  means crash
                lda ZP_TUNNEL_LEFT
                clc
                adc #TUNNEL_W
                sta ZP_TEMP
                lda ZP_ROVER_X
                cmp ZP_TEMP
                bcs .crash
                rts
.crash:
                lda #1
                sta ZP_DEAD
                rts

; ============================================================================
; render_screen — draw the tunnel and rover to screen RAM
; ============================================================================
!zone render_screen
render_screen:
                lda #0
                sta ZP_ROW

.row_loop:
                ; Get screen address for this row from lookup table
                ldx ZP_ROW
                lda row_offset_lo,x
                sta ZP_PTR1
                lda row_offset_hi,x
                clc
                adc #>SCREEN
                sta ZP_PTR1_HI

                lda TUNNEL,x
                sta ZP_TUNNEL_LEFT

                lda #0
                sta ZP_COL

.col_loop:
                ldy ZP_COL

                ; Is this the rover?
                lda ZP_ROW
                cmp #ROVER_ROW
                bne .not_rover
                lda ZP_COL
                cmp ZP_ROVER_X
                bne .not_rover
                lda #ROVER_CHAR
                sta (ZP_PTR1),y
                jmp .next_col

.not_rover:
                ; Is this a wall? col <= left OR col >= left+TUNNEL_W
                lda ZP_COL
                cmp ZP_TUNNEL_LEFT
                beq .draw_wall
                bcc .draw_wall

                lda ZP_TUNNEL_LEFT
                clc
                adc #TUNNEL_W
                sta ZP_TEMP
                lda ZP_COL
                cmp ZP_TEMP
                bcs .draw_wall

                ; Empty space
                lda #EMPTY_CHAR
                sta (ZP_PTR1),y
                jmp .next_col

.draw_wall:
                lda #WALL_CHAR
                sta (ZP_PTR1),y

.next_col:
                inc ZP_COL
                lda ZP_COL
                cmp #SCREEN_W
                bne .col_loop

                inc ZP_ROW
                lda ZP_ROW
                cmp #STATUS_ROW
                bne .row_loop
                rts

; ============================================================================
; display_status — show score on row 24
; ============================================================================
!zone display_status
display_status:
                ; Clear row 24
                lda #EMPTY_CHAR
                ldx #39
.clear:
                sta SCREEN+960,x
                dex
                bpl .clear

                ; Write "SCORE "
                ldx #0
.txt:
                lda txt_score,x
                sta SCREEN+961,x
                inx
                cpx #6
                bne .txt

                ; Write number
                lda ZP_SCORE_LO
                sta ZP_NUM_LO
                lda ZP_SCORE_HI
                sta ZP_NUM_HI
                lda #<(SCREEN+967)
                sta ZP_PTR1
                lda #>(SCREEN+967)
                sta ZP_PTR1_HI
                jsr write_number

                ; Write "  A/D=STEER Q=QUIT"
                ldx #0
.help:
                lda txt_help,x
                sta SCREEN+975,x
                inx
                cpx #18
                bne .help
                rts

;                       S    C    O    R    E   SPC
txt_score:      !byte $13, $03, $0F, $12, $05, $20
;                      SPC  SPC   A    /    D    =    S    T    E    E    R   SPC   Q    =    Q    U    I    T
txt_help:       !byte $20, $20, $01, $2F, $04, $3D, $13, $14, $05, $05, $12, $20, $11, $3D, $11, $15, $09, $14

; ============================================================================
; render_game_over — show game over message
; ============================================================================
!zone render_game_over
render_game_over:
                ; Clear middle area
                lda #EMPTY_CHAR
                ldx #39
.cl1:           sta SCREEN+440,x        ; row 11
                sta SCREEN+480,x        ; row 12
                sta SCREEN+520,x        ; row 13
                dex
                bpl .cl1

                ; "GAME OVER"  on row 12
                ldx #0
.go_txt:
                lda txt_gameover,x
                sta SCREEN+496,x
                inx
                cpx #9
                bne .go_txt
                rts

;                       G    A    M    E   SPC   O    V    E    R
txt_gameover:   !byte $07, $01, $0D, $05, $20, $0F, $16, $05, $12

; ============================================================================
; write_number — write 16-bit ZP_NUM_LO/HI as decimal to (ZP_PTR1)
; ============================================================================
!zone write_number
write_number:
                ldy #0
                lda #0
                sta ZP_LEAD
                ldx #0
.next_digit:
                lda #0
                sta ZP_TEMP
.sub_loop:
                lda ZP_NUM_LO
                sec
                sbc powers_lo,x
                pha
                lda ZP_NUM_HI
                sbc powers_hi,x
                bcc .digit_done
                sta ZP_NUM_HI
                pla
                sta ZP_NUM_LO
                inc ZP_TEMP
                jmp .sub_loop
.digit_done:
                pla
                lda ZP_TEMP
                bne .print_digit
                lda ZP_LEAD
                beq .skip_digit
                lda ZP_TEMP
.print_digit:
                clc
                adc #$30                ; '0' screen code
                sta (ZP_PTR1),y
                iny
                lda #1
                sta ZP_LEAD
.skip_digit:
                inx
                cpx #5
                bne .next_digit
                lda ZP_LEAD
                bne .done
                lda #$30
                sta (ZP_PTR1),y
.done:
                rts

powers_lo:      !byte <10000, <1000, <100, <10, <1
powers_hi:      !byte >10000, >1000, >100, >10, >1

; ============================================================================
; delay_frame — simple busy-wait delay
; ============================================================================
!zone delay_frame
delay_frame:
                ldx #$06
.outer:
                ldy #$00
.inner:
                dey
                bne .inner
                dex
                bne .outer
                rts

; ============================================================================
; set_colours — fill colour RAM with white (1)
; ============================================================================
!zone set_colours
set_colours:
                lda #1                  ; white
                ldx #0
.loop:
                sta COLOR_RAM,x
                sta COLOR_RAM+256,x
                sta COLOR_RAM+512,x
                cpx #(232)
                bcs .skip3
                sta COLOR_RAM+768,x
.skip3:
                inx
                bne .loop
                rts

; --- Row * 40 lookup table (rows 0-24) -------------------------------------
row_offset_lo:
                !byte <(0*40), <(1*40), <(2*40), <(3*40), <(4*40)
                !byte <(5*40), <(6*40), <(7*40), <(8*40), <(9*40)
                !byte <(10*40),<(11*40),<(12*40),<(13*40),<(14*40)
                !byte <(15*40),<(16*40),<(17*40),<(18*40),<(19*40)
                !byte <(20*40),<(21*40),<(22*40),<(23*40),<(24*40)
row_offset_hi:
                !byte >(0*40), >(1*40), >(2*40), >(3*40), >(4*40)
                !byte >(5*40), >(6*40), >(7*40), >(8*40), >(9*40)
                !byte >(10*40),>(11*40),>(12*40),>(13*40),>(14*40)
                !byte >(15*40),>(16*40),>(17*40),>(18*40),>(19*40)
                !byte >(20*40),>(21*40),>(22*40),>(23*40),>(24*40)
