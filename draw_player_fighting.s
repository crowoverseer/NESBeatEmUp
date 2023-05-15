;;; this file exists for code separation and readability
;;; it is should be included into draw_player.s
;;; all imports should be done there

;;; .importzp player_x, player_y, player_flags, player_state

.include "object_states.inc"
  LDA player_state
  CMP #PUNCHING
  BNE no_punch_frame
  JMP draw_punch_frame
no_punch_frame:
  LDX #$FF
  STX $0218
  STX $0219
  STX $021A
  STX $021B
  RTS
draw_punch_frame:
  ;; Y pos, tile number, attributes, X pos
  LDA player_y
  SEC
  SBC #$10
  STA $0218

  LDA #$06                      ; tile number
  CLC
  ADC #START_TILE
  STA $0219

  LDA player_flags
  AND #DIRECT_LEFT
  BEQ right_punch
left_punch:
  LDX #%01000000
  STX $021A                     ; attributes
  LDA player_x
  SEC
  SBC #$08
  JMP write_x_coord
right_punch:
  LDX #$00
  STX $021A                     ; attributes
  LDA player_x
  CLC
  ADC #$10
write_x_coord:
  STA $021B
return:
