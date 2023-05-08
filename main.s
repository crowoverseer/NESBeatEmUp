.include "header.inc"
.include "constants.inc"

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.import draw_player
.import update_player
.import player_controls

.proc nmi_handler
  ;; saving the register states
  PHP
  PHA

  LDA #$00                      ; will transfer to PPU 00
  STA OAMADDR
  LDA #$02                      ; tranfer page from $0200
  STA OAMDMA

  ;; update tiles after DMA transfer
  JSR player_controls
  JSR draw_player

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
  LDA #$00                      ; x is first
  STA PPUSCROLL
  DEC scroll
  LDA scroll                    ; y is second
  STA PPUSCROLL

  ;; restoring the register states
  PLA
  PLP

  RTI
.endproc

.import reset_handler

.export main
.proc main
  ;; initial scroll
  LDA #239                      ; y have only 240 pixels
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
vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA ppuctrl_settings
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK
forever:
  JMP forever
.endproc

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 2
player_dir: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
buffer1: .res 1
.exportzp player_x, player_y, player_dir, pad1, buffer1

.segment "RODATA"
palettes:
  .byte $0f, $12, $23, $27
  .byte $0f, $2b, $3c, $39
  .byte $0f, $0c, $07, $13
  .byte $0f, $19, $09, $29

  .byte $0f, $2d, $10, $15
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29
  .byte $0f, $19, $09, $29

sprites:
  ;; Y pos, tile number, palette, X pos
  .byte PLAYER_Y_INIT - 16, $00, $00, PLAYER_X_INIT
  .byte PLAYER_Y_INIT - 16, $00, $00, PLAYER_X_INIT + 8
  .byte PLAYER_Y_INIT - 8, $00, $00, PLAYER_X_INIT
  .byte PLAYER_Y_INIT - 8, $00, $00, PLAYER_X_INIT + 8
  .byte PLAYER_Y_INIT, $00, $00, PLAYER_X_INIT
  .byte PLAYER_Y_INIT, $00, $00, PLAYER_X_INIT + 8

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "CHR"
.incbin "graphics.chr"
