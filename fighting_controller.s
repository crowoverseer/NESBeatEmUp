;;; registers not protected
;;; checks damage, hits, recoil et cetera...

.include "object_states.inc"
.include "fighting_constants.inc"

.proc fighting_controller
.export fighting_controller
  LDA player_state
  CMP #PUNCHING
  BNE counters
  LDA player_post_punch_frames
  CMP #END_PUNCH_FRAME
  BNE counters
end_punch:
  LDA player_flags
  AND #%11111101
  STA player_flags
  LDA #NOTHING
  STA player_state
counters:
  LDA player_post_punch_frames
  CMP #$4C                      ; 60 seconds
  BEQ return
  INC player_post_punch_frames
return:
  RTS
.endproc

.segment "ZEROPAGE"
player_post_punch_frames: .res 1 ; can't do next punch right after previous
fighting_flags: .res 1 ; some flags about what happened and happens
.importzp player_state, player_flags
.exportzp player_post_punch_frames, fighting_flags
