;;; NOT protected A register
;;; basic player movement system

.include "constants.inc"
.include "object_states.inc"

.macro Read_controller1
  LDA #$01                      ; init the controller
  STA CONTROLLER1
  LDA #$00
  STA CONTROLLER1
  LDA #%00000001
  STA pad1
get_button_states:
  LDA CONTROLLER1
  LSR A
  ROL pad1
  BCC get_button_states
.endmacro

MARGIN = 4                      ; pixel margin for screen
MARGIN_LEFT = 8                 ; because of punching tile
MARGIN_TOP = 100 + MARGIN + 8 + 24 ; top 8 pixels is hidden, player height 24
MARGIN_RIGHT = 16 + MARGIN      ; 16 is player width
MARGIN_BOTTOM = 16 + MARGIN + 8 ; top is 16 pixels less than 255
  ;; Why we need another 8 IDK

.export player_controls
.proc player_controls
  Read_controller1
  CLC
check_left:
  LDA pad1
  AND #BTN_LEFT
  BEQ check_right
  DEC player_x
  LDA player_flags
  ORA #DIRECT_LEFT
  STA player_flags
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x
  LDA player_flags
  AND #%11111110                ; set bit to direction right
  STA player_flags
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  DEC player_y
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ correct_borders
  INC player_y
correct_borders:
check_left_border:
  LDA player_x
  SEC
  SBC #MARGIN_LEFT              ; if X less than MINX, carry will set
  BCS check_right_border
  SEC
  INC player_x
  JMP check_top_border
check_right_border:
  CLC
  LDA player_x
  ADC #MARGIN_RIGHT
  BCC check_top_border
  DEC player_x
check_top_border:
  SEC
  LDA player_y
  SBC #MARGIN_TOP
  BCS check_down_border
  SEC
  INC player_y
  RTS
check_down_border:
  CLC
  LDA player_y
  ADC #MARGIN_BOTTOM
  BCC check_fighting
  DEC player_y
check_fighting:
.include "player_controls_fighting.s"
  RTS
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_flags, player_state
.importzp player_post_punch_frames, pad1, fighting_flags
