; ============================================================================
; Conway's Game of Life — Commodore 64
; Assembler: ACME cross-assembler
;
; Screen: 40x25 characters (using the full text screen)
; Alive = reverse-space (screen code $A0)
; Dead  = space (screen code $20)
; Wraps toroidally (edges connect)
; Press SPACE to pause/resume, Q to quit
;
; Build:  acme -f cbm -o game_of_life.prg game_of_life.asm
; Run:    LOAD "GAME_OF_LIFE",8,1  then  RUN
; ============================================================================

!cpu 6510

; --- Zero-page variables ---------------------------------------------------
ZP_PTR1         = $FB           ; general-purpose pointer (lo)
ZP_PTR1_HI      = $FC           ; general-purpose pointer (hi)
ZP_PTR2         = $FD           ; general-purpose pointer (lo)
ZP_PTR2_HI      = $FE           ; general-purpose pointer (hi)
ZP_TEMP         = $02           ; temp byte
ZP_COUNT        = $03           ; neighbour count
ZP_ROW          = $04           ; current row   (0-24)
ZP_COL          = $05           ; current column (0-39)
ZP_GEN_LO       = $06           ; generation counter lo
ZP_GEN_HI       = $07           ; generation counter hi
ZP_ALIVE_LO     = $08           ; alive-cell count lo
ZP_ALIVE_HI     = $09           ; alive-cell count hi
ZP_NUM_LO       = $0A           ; number-to-decimal scratch lo
ZP_NUM_HI       = $0B           ; number-to-decimal scratch hi
ZP_LEAD         = $0C           ; leading-zero suppression flag

; --- System addresses ------------------------------------------------------
SCREEN          = $0400         ; default screen RAM
COLOR_RAM       = $D800         ; colour RAM
BUFFER          = $C000         ; 1000-byte back-buffer for next generation
BORDER          = $D020
BACKGROUND      = $D021
GETIN           = $FFE4         ; KERNAL: get key from keyboard buffer

; --- Constants -------------------------------------------------------------
SCREEN_W        = 40
SCREEN_H        = 24
SCREEN_SIZE     = SCREEN_W * SCREEN_H   ; 960
ALIVE_CHAR      = $A0           ; reverse space (filled block)
DEAD_CHAR       = $20           ; space

; ============================================================================
; BASIC stub at $0801:  10 SYS 2061
; ============================================================================
                * = $0801

                !byte $0B, $08          ; pointer to next BASIC line ($080B)
                !byte $0A, $00          ; line number 10
                !byte $9E              ; SYS token
                !text "2061"           ; decimal address of 'start'
                !byte $00              ; end of BASIC line
                !byte $00, $00         ; end of BASIC program (null link)

; ============================================================================
; start — entry point at $080D = 2061 decimal
; ============================================================================
start:
                sei                     ; disable IRQs during setup

                ; -- Set border & background colours (original C64) ---------
                lda #$0E                ; light blue
                sta BORDER
                lda #$06                ; dark blue
                sta BACKGROUND

                ; -- Clear generation counter --------------------------------
                sta ZP_GEN_LO
                sta ZP_GEN_HI

                ; -- Seed the screen with a random pattern -------------------
                jsr seed_random

                ; -- Set all colour RAM to green on black --------------------
                jsr set_colours

                cli                     ; re-enable IRQs

; ---- Main loop ------------------------------------------------------------
main_loop:
                jsr compute_generation  ; SCREEN -> BUFFER
                jsr copy_buffer         ; BUFFER -> SCREEN
                jsr inc_generation      ; bump counter
                jsr display_status      ; show gen & alive count

                ; -- Check keyboard -----------------------------------------
                jsr GETIN
                cmp #$20                ; SPACE — pause
                beq pause_loop
                cmp #$51                ; 'Q' — quit
                beq quit
                jmp main_loop

pause_loop:
                jsr GETIN
                cmp #$20
                bne pause_loop
                jmp main_loop

quit:
                rts

; ============================================================================
; seed_random — fill screen with random alive / dead cells using SID noise
; ============================================================================
!zone seed_random
seed_random:
                ; Enable SID channel 3 noise for random numbers
                lda #$FF
                sta $D40E               ; frequency hi
                sta $D40F               ; frequency lo
                lda #$80
                sta $D412               ; voice 3: noise waveform

                ldx #0
.loop:
                lda $D41B               ; SID oscillator 3 (random byte)
                and #$01                ; keep bit 0 only
                beq .put_dead
                lda #ALIVE_CHAR
                jmp .store
.put_dead:
                lda #DEAD_CHAR
.store:
                sta SCREEN,x
                sta SCREEN+256,x
                sta SCREEN+512,x
                cpx #(SCREEN_SIZE - 768) ; remaining bytes (232)
                bcs .skip3
                sta SCREEN+768,x
.skip3:
                inx
                bne .loop
                rts

; ============================================================================
; set_colours — fill colour RAM with green (5)
; ============================================================================
!zone set_colours
set_colours:
                lda #$01                ; white
                ldx #0
.loop:
                sta COLOR_RAM,x
                sta COLOR_RAM+256,x
                sta COLOR_RAM+512,x
                cpx #(SCREEN_SIZE - 768)
                bcs .skip3
                sta COLOR_RAM+768,x
.skip3:
                inx
                bne .loop
                rts

; ============================================================================
; compute_generation — for every cell on SCREEN, count neighbours and write
;                      the result into BUFFER
; ============================================================================
!zone compute_generation
compute_generation:
                lda #0
                sta ZP_ROW
.row_loop:
                lda #0
                sta ZP_COL
.col_loop:
                ; -- Count live neighbours ----------------------------------
                jsr count_neighbours    ; result in ZP_COUNT

                ; -- Compute linear offset of (ROW, COL)
                jsr get_offset          ; returns pointer in ZP_PTR1

                ; -- Read current cell state from SCREEN --------------------
                ldy #0
                lda (ZP_PTR1),y

                cmp #ALIVE_CHAR
                beq .cell_alive

                ; -- Dead cell: becomes alive only with exactly 3 neighbours -
.cell_dead:
                lda ZP_COUNT
                cmp #3
                bne .set_dead
                lda #ALIVE_CHAR
                jmp .write_cell
.set_dead:
                lda #DEAD_CHAR
                jmp .write_cell

                ; -- Alive cell: survives with 2 or 3 neighbours ------------
.cell_alive:
                lda ZP_COUNT
                cmp #2
                beq .set_alive
                cmp #3
                beq .set_alive
                lda #DEAD_CHAR
                jmp .write_cell
.set_alive:
                lda #ALIVE_CHAR

.write_cell:
                ; -- Store into BUFFER at same offset -----------------------
                pha                     ; save cell value on stack
                clc
                lda ZP_PTR1
                adc #<(BUFFER - SCREEN)
                sta ZP_PTR2
                lda ZP_PTR1_HI
                adc #>(BUFFER - SCREEN)
                sta ZP_PTR2_HI

                pla                     ; restore cell value
                ldy #0
                sta (ZP_PTR2),y

                ; -- Advance column -----------------------------------------
                inc ZP_COL
                lda ZP_COL
                cmp #SCREEN_W
                bne .col_loop

                ; -- Advance row --------------------------------------------
                inc ZP_ROW
                lda ZP_ROW
                cmp #SCREEN_H
                bne .row_loop
                rts

; ============================================================================
; count_neighbours — count the 8 neighbours of (ZP_ROW, ZP_COL)
;                    Result in ZP_COUNT.  Uses toroidal wrapping.
; ============================================================================
!zone count_neighbours
count_neighbours:
                lda #0
                sta ZP_COUNT

                ; Iterate dr = -1, 0, +1  and  dc = -1, 0, +1
                ldx #0                  ; index into delta table (0..8)
.nb_loop:
                cpx #9
                beq .nb_done

                ; skip centre (0,0) at index 4
                cpx #4
                beq .nb_next

                ; -- Compute neighbour row with wrapping --------------------
                lda ZP_ROW
                clc
                adc delta_r,x
                bpl .row_not_neg
                ; wrapped below 0: add SCREEN_H
                clc
                adc #SCREEN_H
                jmp .row_ok
.row_not_neg:
                cmp #SCREEN_H
                bcc .row_ok
                ; wrapped past max: subtract SCREEN_H
                sec
                sbc #SCREEN_H
.row_ok:
                sta ZP_TEMP             ; neighbour row

                ; -- Compute neighbour col with wrapping --------------------
                lda ZP_COL
                clc
                adc delta_c,x
                bpl .col_not_neg
                clc
                adc #SCREEN_W
                jmp .col_ok
.col_not_neg:
                cmp #SCREEN_W
                bcc .col_ok
                sec
                sbc #SCREEN_W
.col_ok:
                ; A = neighbour col, ZP_TEMP = neighbour row
                ; offset = row * 40 + col
                tay                     ; Y = col

                ; -- Save X (delta index) on stack --------------------------
                txa
                pha

                ; -- Use lookup table for row*40 (avoids 8-bit overflow) ----
                ldx ZP_TEMP             ; X = neighbour row
                clc
                tya                     ; A = col
                adc row_offset_lo,x     ; + low byte of row*40
                sta ZP_PTR2
                lda row_offset_hi,x     ; high byte of row*40
                adc #0                  ; + carry from col add
                ; Add SCREEN base high byte
                clc
                adc #>SCREEN
                sta ZP_PTR2_HI
                ; SCREEN low byte is $00 so no need to add it

                ; -- Read neighbour cell ------------------------------------
                ldy #0
                lda (ZP_PTR2),y
                cmp #ALIVE_CHAR
                bne .not_alive
                inc ZP_COUNT
.not_alive:
                ; -- Restore X (delta index) --------------------------------
                pla
                tax

.nb_next:
                inx
                jmp .nb_loop
.nb_done:
                rts

; --- Delta tables for the 8+1 directions (including centre at index 4) -----
delta_r:        !byte $FF, $FF, $FF, $00, $00, $00, $01, $01, $01
                ;       -1   -1   -1    0    0    0   +1   +1   +1
delta_c:        !byte $FF, $00, $01, $FF, $00, $01, $FF, $00, $01
                ;       -1    0   +1   -1    0   +1   -1    0   +1

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

; ============================================================================
; get_offset — compute 16-bit screen pointer for (ZP_ROW, ZP_COL)
;              Result in ZP_PTR1 / ZP_PTR1_HI, pointing into SCREEN
; ============================================================================
!zone get_offset
get_offset:
                ; offset = ZP_ROW * 40 + ZP_COL  (using lookup table)
                ldx ZP_ROW
                clc
                lda ZP_COL
                adc row_offset_lo,x     ; col + low byte of row*40
                sta ZP_PTR1
                lda row_offset_hi,x     ; high byte of row*40
                adc #0                  ; + carry from col add
                ; Add SCREEN base high byte ($04)
                clc
                adc #>SCREEN
                sta ZP_PTR1_HI
                ; SCREEN low byte is $00, nothing to add
                rts

; ============================================================================
; copy_buffer — copy 1000 bytes from BUFFER ($C000) to SCREEN ($0400)
; ============================================================================
!zone copy_buffer
copy_buffer:
                ldx #0
.loop:
                lda BUFFER,x
                sta SCREEN,x
                lda BUFFER+256,x
                sta SCREEN+256,x
                lda BUFFER+512,x
                sta SCREEN+512,x
                cpx #(SCREEN_SIZE - 768)
                bcs .skip3
                lda BUFFER+768,x
                sta SCREEN+768,x
.skip3:
                inx
                bne .loop
                rts

; ============================================================================
; inc_generation — increment 16-bit generation counter
; ============================================================================
!zone inc_generation
inc_generation:
                inc ZP_GEN_LO
                bne .done
                inc ZP_GEN_HI
.done:
                rts

; ============================================================================
; display_status — show "GENERATION xxxxx  ALIVE xxx" on row 24
; ============================================================================
!zone display_status
display_status:
                ; -- Clear row 24 with spaces ------------------------------
                lda #DEAD_CHAR
                ldx #39
.clear:
                sta SCREEN+960,x
                dex
                bpl .clear

                ; -- Write "GENERATION " at pos 1 --------------------------
                ldx #0
.gen_txt:
                lda txt_generation,x
                sta SCREEN+961,x
                inx
                cpx #11
                bne .gen_txt

                ; -- Write generation number at pos 12 ---------------------
                lda ZP_GEN_LO
                sta ZP_NUM_LO
                lda ZP_GEN_HI
                sta ZP_NUM_HI
                lda #<(SCREEN+972)
                sta ZP_PTR1
                lda #>(SCREEN+972)
                sta ZP_PTR1_HI
                jsr write_number

                ; -- Write "  ALIVE " at pos 19 ----------------------------
                ldx #0
.alive_txt:
                lda txt_alive,x
                sta SCREEN+979,x
                inx
                cpx #8
                bne .alive_txt

                ; -- Count alive cells and write at pos 27 -----------------
                jsr count_alive
                lda ZP_ALIVE_LO
                sta ZP_NUM_LO
                lda ZP_ALIVE_HI
                sta ZP_NUM_HI
                lda #<(SCREEN+987)
                sta ZP_PTR1
                lda #>(SCREEN+987)
                sta ZP_PTR1_HI
                jsr write_number
                rts

; --- Status line text (C64 screen codes) -----------------------------------
;                       G    E    N    E    R    A    T    I    O    N   SPC
txt_generation: !byte $07, $05, $0E, $05, $12, $01, $14, $09, $0F, $0E, $20
;                      SPC  SPC   A    L    I    V    E   SPC
txt_alive:      !byte $20, $20, $01, $0C, $09, $16, $05, $20

; ============================================================================
; count_alive — count ALIVE_CHAR cells in the first 24 rows (960 bytes)
;              Result in ZP_ALIVE_LO / ZP_ALIVE_HI
; ============================================================================
!zone count_alive
count_alive:
                lda #0
                sta ZP_ALIVE_LO
                sta ZP_ALIVE_HI
                lda #<SCREEN
                sta ZP_PTR1
                lda #>SCREEN
                sta ZP_PTR1_HI

                ldx #3                  ; 3 full pages (768 bytes)
                ldy #0
.page_loop:
                lda (ZP_PTR1),y
                cmp #ALIVE_CHAR
                bne .skip1
                inc ZP_ALIVE_LO
                bne .skip1
                inc ZP_ALIVE_HI
.skip1:
                iny
                bne .page_loop
                inc ZP_PTR1_HI
                dex
                bne .page_loop

                ; Remaining 192 bytes (960 - 768)
.remain_loop:
                lda (ZP_PTR1),y
                cmp #ALIVE_CHAR
                bne .skip2
                inc ZP_ALIVE_LO
                bne .skip2
                inc ZP_ALIVE_HI
.skip2:
                iny
                cpy #192
                bne .remain_loop
                rts

; ============================================================================
; write_number — write 16-bit number as decimal digits to screen
;   Input:  ZP_NUM_LO/HI = number, ZP_PTR1/HI = screen position
;   Output: digits written at (ZP_PTR1),Y  (leading zeros suppressed)
; ============================================================================
!zone write_number
write_number:
                ldy #0                  ; screen offset
                lda #0
                sta ZP_LEAD             ; 0 = still skipping leading zeros
                ldx #0                  ; powers-of-10 table index
.next_digit:
                lda #0
                sta ZP_TEMP             ; digit counter
.sub_loop:
                lda ZP_NUM_LO
                sec
                sbc powers_lo,x
                pha
                lda ZP_NUM_HI
                sbc powers_hi,x
                bcc .digit_done         ; underflow — digit is finished
                sta ZP_NUM_HI
                pla
                sta ZP_NUM_LO
                inc ZP_TEMP
                jmp .sub_loop
.digit_done:
                pla                     ; discard underflowed low byte
                lda ZP_TEMP
                bne .print_digit
                ; Digit is 0 — skip if still leading zeros
                lda ZP_LEAD
                beq .skip_digit
                lda ZP_TEMP             ; print a real '0'
.print_digit:
                clc
                adc #$30                ; convert 0-9 → screen code '0'-'9'
                sta (ZP_PTR1),y
                iny
                lda #1
                sta ZP_LEAD             ; no longer leading
.skip_digit:
                inx
                cpx #5
                bne .next_digit

                ; If the entire number was 0, print a single '0'
                lda ZP_LEAD
                bne .wr_done
                lda #$30
                sta (ZP_PTR1),y
.wr_done:
                rts

; --- Powers of 10 (16-bit, high to low) ------------------------------------
powers_lo:      !byte <10000, <1000, <100, <10, <1
powers_hi:      !byte >10000, >1000, >100, >10, >1
