;;; Not protected A, X

;;; There is 5 npc max
;;; The memory location 50-83

.include "constants.inc"

;;; Adress 50 contains total npc count

;;; Each npc have 10 bytes of information
.include "npc_controller.inc"

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
  TAX                           ; there X contains NPC_COUNT
  LDA #0                        ; there A contains current npc offset
  CLC
get_spawn_offset:
  DEX
  BMI write_new_data
  ADC #NPC_RUNDATA_LENGTH
  JMP get_spawn_offset
write_new_data:
  INC NPC_COUNT
  TAX                           ; X contains npc memory offset
  LDA SPAWN_NPC_ID_ARG
  STA npc_objects + NPC_ID, X
  LDA SPAWN_NPC_TOP_ARG
  STA npc_objects + NPC_TOP, X
  LDA SPAWN_NPC_LEFT_ARG
  STA npc_objects + NPC_LEFT, X
  LDA $A0                       ; ten hitpoints. TODO: get from npc_data
  STA npc_objects + NPC_LIFE, X            ; life
  LDA $00
  STA npc_objects + NPC_STATE, X
  STA npc_objects + NPC_ANIM_SPRITE, X
  STA npc_objects + NPC_ANIM_FRAMES_PASS, X
  STA npc_objects + NPC_FIGHTING_FLAGS, X
  STA npc_objects + NPC_PUNCH_FRAMES_PASS, X
  RTS
.endproc

.segment "NPCRUNDATA"
.export npc_objects
npc_objects:
.res 9 * MAX_NPC_COUNT
