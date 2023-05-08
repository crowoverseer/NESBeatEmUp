.include "constants.inc"
.import main

.segment "CODE"
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$00
  STX PPUCTRL
  STX PPUMASK
vblankwait:
  BIT PPUSTATUS
  BPL vblankwait
  ;; clear any garbage data in video RAM
  LDX #$00
  LDA #$ff
  CLC
clear_oam:
  STA $0200, X ; set sprite y-position off the screen
  INX
  INX
  INX
  INX
  BNE clear_oam
  JMP main
  ;; initialize zero-page values
  LDA #$80
  STA player_x
  LDA #$a0
  STA player_y
vblankwait2:
  BIT PPUSTATUS
  BPL vblankwait2
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y