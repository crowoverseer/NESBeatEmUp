;;; Not protected A, X, Y

START_TILE = $00

.export draw_player
.proc draw_player
  ;; write player tile numbers
  LDX #$00
  LDY #START_TILE
  CLC
next_tile_graphic:
  TYA
  STA $0201, X
  INY
  TXA
  ADC #$04
  CMP #24
  BEQ attributes
  TAX
  JMP next_tile_graphic
attributes:
  ;; write player tile attributes
  ;; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ;; store tile locations
  LDA player_y
  SEC
  SBC #$10                       ; top sprites 16 pixels up
  TAY                            ; Y contains Y pos
  LDX #0                         ; X will 0.4.24, - 0-7 tile address
next_tile:
  ;; store Y pos
  TYA
  STA $0200, X
  ;; store X pos - left column
  INX
  INX
  INX
  LDA player_x
  STA $0200, X
  INX
  ;; store Y pos - right column
  TYA
  STA $0200, X
  ;; store X pos - right column
  INX
  INX
  INX
  LDA player_x
  CLC
  ADC #08
  STA $0200, X
  INX
  ;; next tile
  TXA
  CMP #24
  BEQ return
  TYA
  ADC #$08
  TAY                           ; next level of tiles
  JMP next_tile
return:
  RTS
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, buffer1
