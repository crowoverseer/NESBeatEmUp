;;; should be included into player_controls.s
;;; all imports should be done there
;;; this file exists for better readability and organisation

.include "constants.inc"
.include "object_states.inc"
.include "fighting_constants.inc"

;;; .importzp player_flags, player_state, fighting_flags
;;; .importzp player_post_punch_frames, pad1

check_punch:
  LDA pad1
  AND #BTN_B
  BEQ check_unrelease
  ;; check if button has been released
  LDA fighting_flags
  AND #PLAYER_B_ALREADY_PRESSED
  BNE return
  ;; check for frame count after prevoius punch
  LDA player_post_punch_frames
  CMP #POST_PUNCH_FRAME_LIMIT
  BCC return
  ;; set player punch state
  LDA player_flags
  ORA #ATTACKING
  STA player_flags
  LDA #PUNCHING
  STA player_state
  ;; reset frame counter
  LDA #$00
  STA player_post_punch_frames
  ;; set B pressed
  LDA fighting_flags
  ORA #PLAYER_B_ALREADY_PRESSED
  STA fighting_flags
  JMP return
check_unrelease:
  LDA fighting_flags
  AND #PLAYER_B_ALREADY_PRESSED
  BEQ return
  LDA fighting_flags
  AND #%11111101
  STA fighting_flags
return:
