;;; Not protected A, X

;;; There is 5 npc max
;;; The memory location 50-83

;;; Adress 50 contains total npc count

;;; Each npc have 10 bytes of information
  NPC_ID = 0
  NPC_TOP = 1
  NPC_LEFT = 2
  NPC_FLAGS = 3
  NPC_STATE = 4
  NPC_LIFE = 5
  NPC_ANIM_SPRITE = 6
  NPC_ANIM_FRAMES_PASS = 7
  NPC_FIGHTING_FLAGS = 8
  NPC_PUNCH_FRAMES_PASS = 9

  NPC_COUNT = $50
  MAX_NPC_COUNT = 5
  NPC_RUNDATA_LENGTH = $A0

;;; arguments
  SPAWN_NPC_ID_ARG = $F0
  SPAWN_NPC_TOP_ARG = $F1
  SPAWN_NPC_LEFT_ARG = $F2

.proc create_npc
.export create_npc
  ;; check for maximum
  LDA NPC_COUNT
  CMP #MAX_NPC_COUNT
  BNE start_spawning
  RTS
start_spawning:
  ;; get offset
  TAX
  LDA #0
get_spawn_offset:
  DEX
  BEQ write_new_data
  CLC
  ADC #NPC_RUNDATA_LENGTH
  JMP get_spawn_offset
write_new_data:
  INC NPC_COUNT
  TAX
  LDA SPAWN_NPC_ID_ARG
  STA objects + NPC_ID, X
  LDA SPAWN_NPC_TOP_ARG
  STA objects + NPC_TOP, X
  LDA SPAWN_NPC_LEFT_ARG
  STA objects + NPC_LEFT, X
  LDA $A0                       ; ten hitpoints. TODO: get from npc_data
  STA objects + NPC_LIFE, X            ; life
  LDA $00
  STA objects + NPC_STATE, X
  STA objects + NPC_ANIM_SPRITE, X
  STA objects + NPC_ANIM_FRAMES_PASS, X
  STA objects + NPC_FIGHTING_FLAGS, X
  STA objects + NPC_PUNCH_FRAMES_PASS, X
.endproc

.segment "NPCRUNDATA"
objects:
.res 9 * MAX_NPC_COUNT
