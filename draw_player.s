;;; Not protected A, X, Y

.include "object_states.inc"

START_TILE_FRAME_1 = $00
START_TILE_FRAME_2 = $08
START_TILE_FRAME_3 = $10

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
  ;; saving registers
  PHA                           ; A first
  TXA
  PHA                           ; X second
  ;; looking for current animation frame
  LDX player_frame
  CPX #$01
  BEQ frame_2
  CPX #$02
  BEQ frame_3
frame_1:
  LDA #START_TILE_FRAME_1
  JMP write_tile_with_offset
frame_2:
  LDA #START_TILE_FRAME_2
  JMP write_tile_with_offset
frame_3:
  LDA #START_TILE_FRAME_3
write_tile_with_offset:
  STA buffer                    ; there is tile offset
  ;; restoring registers
  PLA
  TAX
  PLA
  CLC
  ADC buffer
  STA $0201, X
  TXA
  CLC
  ADC #$04
  TAX
end_loop_operations:
  INY
  TXA
  CMP #32                       ; 8 tiles for 4 bites
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
  CMP #$08                      ; 8 tiles
  BNE next_attribute
write_positions:
  ;; store tile positions
  LDA player_y
  SEC
  SBC #$20                       ; top sprites 32 pixels up
  TAY                            ; Y contains Y pos
  LDX #0                         ; X will 0.4.32, - 6*4 tile address
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
  CMP #32
  BEQ draw_fighting
  TYA
  ADC #$08
  TAY                           ; next level of tiles
  JMP next_tile
draw_fighting:
  LDA current_sprite
  CLC
  ADC #$08
  STA current_sprite
.include "draw_player_fighting.s"
  RTS
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_flags, player_frame, buffer
.importzp player_state, current_sprite
