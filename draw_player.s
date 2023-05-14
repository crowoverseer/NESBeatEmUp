;;; Not protected A, X, Y

.include "object_states.inc"

START_TILE = $00

.export draw_player
.proc draw_player
  ;; write player tile numbers
  LDX #$00                      ; tile memory address
  LDY #$00                      ; tile offset
next_tile_graphic:
  ;; flip check
  LDA player_flags
  AND #DIRECT_LEFT
  BEQ normal_tile_sequence
flipped_tile_sequence:
  ;; if tile num is odd => -1 tile, else +1 tile
  TYA
  AND #%00000001
  BEQ even_tile
odd_tile:
  TYA
  SEC
  SBC #$01
  JMP write_tile
even_tile:
  TYA
  CLC
  ADC #$01
  JMP write_tile
normal_tile_sequence:
  TYA
write_tile:
  CLC
  ADC #START_TILE
  STA $0201, X
  TXA
  CLC
  ADC #$04
  TAX
end_loop_operations:
  INY
  TXA
  CMP #24
  BEQ attributes
  JMP next_tile_graphic
attributes:
  ;; write player tile attributes
  ;; use palette 0
  LDX #$00
  ;; direct left or right
  LDA player_flags
  AND #DIRECT_LEFT
  BEQ write_attribute_info
  LDX #%01000000                 ; flip horizontally
write_attribute_info:
  STX $0202
  STX $0206
  STX $020a
  STX $020e
  STX $0212
  STX $0216

  ;; store tile locations
  LDA player_y
  SEC
  SBC #$10                       ; top sprites 16 pixels up
  TAY                            ; Y contains Y pos
  LDX #0                         ; X will 0.4.24, - 6*4 tile address
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
.importzp player_x, player_y, player_flags
