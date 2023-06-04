.include "header.inc"
.include "constants.inc"
.include "guard_registry.mac"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import player_controls
.import fighting_controller
.import npc_artist
.import draw_player

.proc nmi_handler
  ;; saving the register states
  Save_registry

  LDA #$00                      ; will transfer to PPU 00
  STA OAMADDR
  LDA #$02                      ; tranfer page from $0200
  STA OAMDMA

  ;; reset current sprite
  LDA #$00
  STA current_sprite
  ;; update tiles after DMA transfer
  JSR player_controls
  JSR fighting_controller
  JSR draw_player
  JSR npc_artist

  LDA scroll
  CMP $00                       ; did we scroll to the end?
  BNE set_scroll_positions
  LDA ppuctrl_settings
  EOR #%00000010                ; flip bit #1 to its opposite
  STA ppuctrl_settings          ; switched one of two nametables
  STA PPUCTRL                   ; removing artifacts at the egdes
  LDA #240
  STA scroll
set_scroll_positions:
  LDA scroll                    ; x is first
  STA PPUSCROLL
  LDA #$00                      ; y is second
  STA PPUSCROLL

  ;; restoring the register states
  Restore_registry

  RTI
.endproc

.import reset_handler
.import create_npc

.export main
.proc main
  ;; initial scroll
  LDA #0
  STA scroll
  ;; write palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes, X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes
  ;; write sprite data
  LDX #$00
load_sprites:
  LDA sprites, X
  STA $0200, X
  INX
  CPX #24                       ; 24 sprites of player
  BNE load_sprites
  ;; set player initial positions
  LDA #PLAYER_X_INIT
  STA player_x
  LDA #PLAYER_Y_INIT
  STA player_y
  ;; player initial state
  LDX #%00000000
  STX player_flags
  STX fighting_flags
  STX player_anim_frame_pass
  STX player_frame
vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK
create_npcs:
  LDA #$00
  STA $F0
  LDA #$C1
  STA $F1
  LDA #$80
  STA $F2
  JSR create_npc
forever:
  JMP forever
.endproc

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
player_flags: .res 1
player_state: .res 1
player_frame: .res 1            ; current animation frame (sprite)
player_anim_frame_pass: .res 1  ; used for remember how many frames passed
                                ; after previous animation
scroll: .res 1
ppuctrl_settings: .res 1
pad1: .res 1                    ; separate memory for easy debugging
buffer: .res 1
buffer_2: .res 1
current_sprite: .res 1          ; how many sprites drawn
.exportzp player_x, player_y, player_flags, player_state, player_frame
.exportzp player_anim_frame_pass, pad1, buffer, buffer_2, current_sprite
.importzp fighting_flags

.segment "RODATA"
palettes:
  .byte $0f, $0d, $11, $26
  .byte $0f, $2b, $3c, $39
  .byte $0f, $0c, $07, $13
  .byte $0f, $19, $09, $29

  .byte $0f, $0d, $11, $26
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29

sprites:

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"
