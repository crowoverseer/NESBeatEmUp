;;; Not protected A, X, Y

.include "constants.inc"
.include "object_states.inc"

;;; Params:

  START_TILE  = $F0 ; Position of starting tile in bank
  SPRITE_W    = $F1 ; Sprite width in tiles
  SPRITE_H    = $F2 ; Sprite height in tiles
  ATTRIBUTES  = $F3 ; Attributes for sprites
  POS_X       = $F4 ; Sprite position X
  POS_Y       = $F5 ; Sprite position Y

  CALCULATED_FINAL_OFFSET = NON_ZP_BUFFER ; Here will be written
                                ; memory address
                                ; of final RAM tile. Needed to stop proc
  INITIAL_OFFSET = NON_ZP_BUFFER_2

.export draw_sprite
.proc draw_sprite
  ;; calculate final memory address
  ;; TODO only 64 tiles are supported now
  LDA current_sprite            ; tile memory address
  CLC
  ROL
  ROL
  TAX                           ; X contains memory tile offset
  STA INITIAL_OFFSET
  ;; count tiles
  LDA #$00
  LDY SPRITE_H
next_row_for_offset:
  ADC SPRITE_W
  DEY
  BNE next_row_for_offset
  STA buffer_2                  ; ZP buffer_2 will contain tile count
  ;; add tiles count to final offset
  ;; each tile - 4 byte
  ROL
  ROL
  ADC INITIAL_OFFSET
  STA CALCULATED_FINAL_OFFSET
add_to_offset:
  ;; TODO: currently X cannot be more than 255, so there are limit to 64 tiles
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
  CMP CALCULATED_FINAL_OFFSET
  BEQ write_attributes
  JMP next_tile_graphic
write_attributes:
  ;; write sprite tile attributes
  LDY ATTRIBUTES
  CLC
  LDA current_sprite
  ROL                           ; *4, because tile contains 4 bytes
  ROL
  ADC INITIAL_OFFSET
next_attribute:
  TAX
  TYA                           ; Y contains atrributes
  STA $0202, X                  ; attribute bite is second
  TXA
  ADC #$04
  CMP CALCULATED_FINAL_OFFSET
  BNE next_attribute
adjust_sprites_count:
  CLC
  LDA current_sprite
  ADC buffer_2
  STA current_sprite
write_positions:
  ;; calculate top sprite position
  LDX SPRITE_H
  STX buffer                     ; buffer contains rows left
  LDX INITIAL_OFFSET
next_column:
  TXA                           ; we need X for a while
  PHA
  LDX buffer
  LDA POS_Y
subtract_height:
  DEX
  BMI height_calculated
  SEC
  SBC #$08                       ; tile height - 8 pixels
  JMP subtract_height
height_calculated:
  TAY                           ; Y contains current Y pos
  PLA                           ; restoring X
  TAX
  LDA #$00
  STA buffer_2                   ; buffer_2 contains current column
row_coords:
  ;; write Y coord
  TYA
  STA $0200, X
  ;; write X coord
  ;; save y
  PHA
  LDA POS_X
  LDY buffer_2                  ; current column
adjust_x_pos:
  DEY
  BMI x_adjusted
  CLC
  ADC #$08
  JMP adjust_x_pos
x_adjusted:
  STA $0203, X
  ;; restore y
  PLA
  TAY
  TXA
  ;; check for finish
  CLC
  ADC #$04
  CMP CALCULATED_FINAL_OFFSET
  BEQ return
  TAX
  LDA buffer_2                  ; buffer 2 - current column
  CLC
  ADC #$01
  CMP SPRITE_W
  BEQ switch_to_next_row
  INC buffer_2
  JMP row_coords
switch_to_next_row:
  DEC buffer                    ; buffer contains rows left
  LDA #00
  STA buffer_2
  JMP next_column
return:
.endproc

.segment "ZEROPAGE"
.importzp buffer, buffer_2
.importzp current_sprite
