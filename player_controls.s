;;; NOT protected A,X registers
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
FRAME_TO_NEXT_ANIM = 10         ; how many CRT frames to next animation frame

.export player_controls
.proc player_controls
  Read_controller1
  CLC
  LDX #0                        ; X is flag for anim frame
                                ; 0 - reset
                                ; >0 - increase frame cnt for ONE
                                ; always ONE, even if X is > 1
check_left:
  LDA pad1
  AND #BTN_LEFT
  BEQ check_right
  DEC player_x
  LDA player_flags
  ORA #DIRECT_LEFT
  STA player_flags
  INX                           ; need to increase animation frame
  JMP check_up
check_right:
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  INC player_x
  LDA player_flags
  AND #%11111110                ; set bit to direction right
  STA player_flags
  INX
check_up:
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  DEC player_y
  INX
check_down:
  LDA pad1
  AND #BTN_DOWN
  BEQ correct_borders
  INC player_y
  INX
correct_borders:
check_left_border:
  LDA player_x
  SEC
  SBC #MARGIN_LEFT              ; if X less than MINX, carry will set
  BCS check_right_border
  SEC
  INC player_x
  DEX
  JMP check_top_border
check_right_border:
  CLC
  LDA player_x
  ADC #MARGIN_RIGHT
  BCC check_top_border
  DEC player_x
  DEX
check_top_border:
  SEC
  LDA player_y
  SBC #MARGIN_TOP
  BCS check_down_border
  SEC
  INC player_y
  DEX
  JMP animation_frames_adj
check_down_border:
  CLC
  LDA player_y
  ADC #MARGIN_BOTTOM
  BCC animation_frames_adj
  DEC player_y
  DEX
animation_frames_adj:
  CLC
  CPX #00
  BEQ reset_frame
  LDX player_anim_frame_pass
  INX
  STX player_anim_frame_pass
  CLC
  CPX #FRAME_TO_NEXT_ANIM
  BNE draw_fighting
  LDX player_frame
  INX
  CPX #03
  BEQ reset_frame
  STX player_frame
  LDX #00
  STX player_anim_frame_pass
  JMP draw_fighting
reset_frame:
  LDX #00
  STX player_frame
  STX player_anim_frame_pass
draw_fighting:
.include "player_controls_fighting.s"
  RTS
.endproc

.segment "ZEROPAGE"
.importzp player_x, player_y, player_flags, player_state
.importzp player_anim_frame_pass, player_frame, buffer
.importzp player_post_punch_frames, pad1, fighting_flags
