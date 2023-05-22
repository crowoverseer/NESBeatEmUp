;;; Not protected A, X, Y

.include "object_states.inc"

.import draw_sprite

START_TILE_FRAME_1 = $00
START_TILE_FRAME_2 = $08
START_TILE_FRAME_3 = $10

.export draw_player
.proc draw_player
  LDA #$02
  STA $F1
  LDA #$04
  STA $F2
  ;; attributes
  ;; mirror flip check
  LDX #%00000000                ; patette 0, no flip
  LDA player_flags
  AND #DIRECT_LEFT
  BEQ write_attributes
  LDX #%01000000                ; palette 0, flip
write_attributes:
  STX $F3
  LDA player_x
  STA $F4
  LDA player_y
  STA $F5
  ;; looking for current animation frame
  LDA player_state
  CMP #PUNCHING
  BNE check_walking
  JMP draw_player_fighting
check_walking:
  LDX player_frame
  CPX #$01
  BEQ frame_2
  CPX #$02
  BEQ frame_3
frame_1:
  LDA #START_TILE_FRAME_1
  JMP write_tile_offset
frame_2:
  LDA #START_TILE_FRAME_2
  JMP write_tile_offset
frame_3:
  LDA #START_TILE_FRAME_3
write_tile_offset:
  STA $F0                    ; there is tile offset
  JSR draw_sprite
draw_player_fighting:
.include "draw_player_fighting.s"
  RTS
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_flags, player_frame, buffer
.importzp player_state, current_sprite
