;;; Not protected A, X, Y

;;; Params:

  START_TILE  = $F0 ; Position of starting tile in bank
  SPRITE_W    = $F1 ; Sprite width in tiles
  SPRITE_H    = $F2 ; Sprite height in tiles
  ATTRIBUTES  = $F3 ; Attributes for sprites
  POS_X       = $F4 ; Sprite position X
  POS_Y       = $F5 ; Sprite position Y

.include "object_states.inc"
.include "constants.inc"

.export draw_sprite
.proc draw_sprite
  ;; write player tile numbers
  LDX current_sprite            ; tile memory address
  LDY #$00                      ; tile offset
next_tile_graphic:
  LDA ATTRIBUTES
  AND #%01000000
  BEQ normal_tile_sequence
flipped_tile_sequence:
  ;; when flipped, first tile is shifted to width - 1
  ;; and each next tile is shifted -1 tile
  ;; current shift will be saved in buffer
  ;; step 1. Find tile position in a row
  SEC
  TYA                           ; Y contains tile offset
remove_next_width:              ; we will remove width until
  SBC SPRITE_W                    ; just offset remains
  BCS remove_next_width
  ADC SPRITE_W
  STA buffer
  ;; we will need an X register
  TXA
  PHA
  ;; step 2. Add to position width - 1
  TYA
  CLC
  ADC SPRITE_W
  SEC
  SBC #01
  ;; step 3. Each time >0 decrease position at 2
  LDX #$00                      ; counter
check_for_subtraction:
  CPX buffer
  BEQ restore_registers
  SBC #$01                      ; -1 for each tile
  INX
  JMP check_for_subtraction
restore_registers:
  STA buffer
  PLA                           ; restore X register
  TAX
  LDA buffer
  CLC

  JMP write_tile
normal_tile_sequence:
  TYA
write_tile:
  ;; A should contain tile offset
  ;; saving registers
  PHA                           ; A first
write_tile_with_offset:
  LDA START_TILE
  STA buffer                    ; there will be tile offset
  ;; restoring registers
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
  BEQ write_attributes
  JMP next_tile_graphic
write_attributes:
  ;; write player tile attributes
  ;; use palette 0
  LDY ATTRIBUTES
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
  LDA POS_Y
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
  LDA POS_X
  STA $0200, X
  INX
  ;; store Y pos - right column
  TYA
  STA $0200, X
  ;; store X pos - right column
  INX
  INX
  INX
  LDA POS_X
  CLC
  ADC #08
  STA $0200, X
  INX
  ;; next tile
  TXA
  CMP #32
  BEQ adjust_cur_sprite_cnt
  TYA
  ADC #$08
  TAY                           ; next level of tiles
  JMP next_tile
adjust_cur_sprite_cnt:
  STA DEBUGGER
  LDA current_sprite
  LDX SPRITE_H
  CLC
add_next_row_to_cur_spr:
  ADC SPRITE_W
  DEX
  BEQ return
  JMP add_next_row_to_cur_spr
return:
  STA current_sprite
  RTS
.endproc

.segment "ZEROPAGE"
.importzp buffer
.importzp current_sprite
