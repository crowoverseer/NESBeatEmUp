;;; this file exists for code separation and readability
;;; it is should be included into draw_player.s
;;; all imports should be done there

;;; .importzp player_x, player_y, player_flags, player_state, player_frame

.include "constants.inc"

  FIRST_ATTACK_TILE = $18
  FIRST_PUNCH_TILE  = $20

.macro Calculate_offset
  LDA current_sprite
  CLC
  ROL                           ; memory offset is
  ROL                           ; current_sprite * 4
  TAX                           ; sprite offset is here
.endmacro

.include "object_states.inc"
  LDA player_state
  CMP #PUNCHING
  BNE no_punch_frame
  JMP draw_punch_frame
no_punch_frame:
  Calculate_offset
  LDA #$FF
  STA $0200, X
  STA $0201, X
  STA $0202, X
  STA $0203, X
  STA $0204, X
  STA $0205, X
  STA $0206, X
  STA $0207, X
  RTS
draw_punch_frame:
  ;; draw rectangle
  LDA #FIRST_ATTACK_TILE
  STA $F0
  JSR draw_sprite
  Calculate_offset
  ;; draw two additional punch tiles
  ;; Y pos, tile number, attributes, X pos
  LDA player_y                  ; y position
  SEC
  SBC #$18
  STA $0204, X
  SBC #$08
  STA $0200, X

  LDA #FIRST_PUNCH_TILE         ; tile number
  STA $0201, X
  STA $0205, X
  INC $0205, X

  LDA player_flags
  AND #DIRECT_LEFT
  BEQ right_punch
left_punch:
  LDA #%01000000
  STA $0202, X                  ; attributes
  STA $0206, X
  LDA player_x
  SEC
  SBC #$08
  jmp write_x_coord
right_punch:
  LDA #$00
  STA $0202, X                  ; attributes
  STA $0206, X

  LDA player_x
  CLC
  ADC #$10
write_x_coord:
  STA $0203, X
  STA $0207, X
  INC current_sprite
  INC current_sprite
return:
