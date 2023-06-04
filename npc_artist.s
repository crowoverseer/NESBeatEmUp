;;; Not protected A, X, Y

;;; Draws NPC into graphic memory, by data in
;;; NPC_RUNDATA segment

.include "npc_controller.inc"
.include "npc_data.s"
.include "constants.inc"

.import draw_sprite

.proc npc_artist
.export npc_artist
  ;; read npc_count
  LDY NPC_COUNT                 ; Y contains current NPC counter
  LDX #$00                      ; X contains offset to NPC_RUNDATA
  ;; check if npc list are ended
next_npc:
  DEY
  BPL process_npc
  RTS
process_npc:
  ;; read npc id
  LDA npc_objects + NPC_ID, X
  ;; get sprite info
  ;; TO DO: now there is no NPC_DATA, so it skipped
  ;; get animation frame number
  LDA npc_objects + NPC_ANIM_SPRITE, X
  ;; get sprite offset
  ;; TO DO: right now only fist animation sprite of OLDMAN
  LDA #OLDMAN_WALK_FRAME_1
  STA $F0
  ;; get width
  ;; TO DO: right now hadcoded
  LDA #$02
  STA $F1
  ;; get height
  ;; TO DO: right now hadcoded
  LDA #$04
  STA $F2
  ;; get attributes
  ;; TO DO: right now hardcoded
  LDA #%01000000                ; palette 0, flip
  STA $F3
  ;; get x
  LDA npc_objects + NPC_LEFT, X
  STA $F4
  ;; get y
  LDA npc_objects + NPC_TOP, X
  STA $F5
  ;; draw sprite
  TYA
  PHA
  TXA
  PHA
  JSR draw_sprite
  PLA
  TAX
  PLA
  TAY
  ;; next iter
  TXA
  ADC #NPC_RUNDATA_LENGTH
  TAX
  JMP next_npc
.endproc

.import npc_objects, buffer
