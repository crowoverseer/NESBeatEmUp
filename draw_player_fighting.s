;;; this file exists for code separation and readability
;;; it is should be included into draw_player.s
;;; all imports should be done there

;;; .importzp player_x, player_y, player_flags, player_state

.include "object_states.inc"
  CLC
  LDA current_sprite
  ROL
  ROL
  TAX                           ; sprite offset is here

  LDA player_state
  CMP #PUNCHING
  BNE no_punch_frame
  JMP draw_punch_frame
no_punch_frame:
  LDA #$FF
  STA $0200, X
  STA $0201, X
  STA $0202, X
  STA $0203, X
  RTS
draw_punch_frame:
  ;; Y pos, tile number, attributes, X pos
  LDA player_y                  ; y position
  SEC
  SBC #$10
  STA $0200, X

  LDA #$06                      ; tile number
  CLC
  ADC #START_TILE
  STA $0201, X

  LDA player_flags
  AND #DIRECT_LEFT
  BEQ right_punch
left_punch:
  LDA #%01000000
  STA $0202, X                  ; attributes
  LDA player_x
  SEC
  SBC #$08
  jmp write_x_coord
right_punch:
  LDA #$00
  STA $0202, X                  ; attributes

  LDA player_x
  CLC
  ADC #$10
write_x_coord:
  STA $0203, X
  INC current_sprite
return:
