;;; Not protected A, X, Y

.include "object_states.inc"

START_TILE = $00

.export draw_player
.proc draw_player
  ;; write player tile numbers
  LDX current_sprite                      ; tile memory address
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
  LDY #%00000000
  ;; direct left or right
  LDA player_flags
  AND #DIRECT_LEFT
  BEQ write_attributes_start
  LDY #%01000000                ; flip horizontally
write_attributes_start:
  CLC
  LDA #00
  STA buffer                    ; how many tiles are written
  LDA current_sprite
  ROL                           ; *4, because tile contains 4 bytes
  ROL
  TAX
next_attribute:
  TYA                           ; Y contains atrributes
  STA $0202, X                  ; attribute bite is second
  TXA
  ADC #$04
  TAX
  INC buffer
  LDA buffer
  CMP #$06
  BNE next_attribute
write_positions:
  ;; store tile positions
  LDA player_y
  SEC
  SBC #$18                       ; top sprites 24 pixels up
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
  BEQ draw_fighting
  TYA
  ADC #$08
  TAY                           ; next level of tiles
  JMP next_tile
draw_fighting:
  LDA current_sprite
  CLC
  ADC #$06
  STA current_sprite
.include "draw_player_fighting.s"
  RTS
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_flags, buffer
.importzp player_state, current_sprite
