                *=$1000
                IncBin "adventure.dat",$02
                *=$3600
                incbin "finn.spt",1,2,true
                *=$3680
                incbin "jake.spt",1,2,true
                *=$3800
                incbin "logo.cst",0,196

                       * = $0801
                incasm "macros.asm"
sysline:        
                byte $0b,$08,$01,$00,$9e,$32,$30,$36,$31,$00,$00,$00 ;= SYS 2061
                * = $080d
                sei             ;disable interrupt flag
                jsr clear_screen
                jsr print_logo
                jsr setup_sprite
                ldy #%0111111
                sty $dc0d
                sty $dd0d
                lda $dc0d
                lda $dd0d       ;cancel all cia-irq interrupts
                lda #$01
                sta $d01a       ;bit1 = irq rasterbeam aka once every drawn frame
                sta $d019
                lda #<irq
                ldx #>irq       ;get pointer to irq routine
                sta $314        ;store low addr
                stx $315        ;store hi addr
                lda #$00        ;trigger interrupt @ row 0 (of screen)
                sta $d012
                ;lda $d011       ;we need to borrow 1 bit (screen is 320 pixels > 255)
                ;and #$7f        ;which is the last bit
                ;sta $d011
                cli             ;clear interrupt flag
                lda #$00
                jsr $1000      ;init music
loop            jmp loop

irq             dec $d019       ;tell irq HEY! im here and everything is fiiiiine
                jsr scroll_message
                lda #<irq2
                ldx #>irq2       ;get pointer to irq routine
                sta $314        ;store low addr
                stx $315        ;store hi addr
                lda #$4f        ;trigger interrupt @ row 16 (of screen)
                sta $d012
                lda $d011       ;reset, since we dont need that last bits
                and #%0111111
                sta $d011
                jmp $ea81       

irq2            dec $d019       ;tell irq HEY! im here and everything is fiiiiine
                jsr update_sprite
                jsr update_logo
                jsr $1003      ;play music
                lda #<irq
                ldx #>irq       ;get pointer to irq routine
                sta $314        ;store low addr
                stx $315        ;store hi addr
                lda #$00        ;trigger interrupt @ row 320 (of screen)
                sta $d012
                ;lda $d011       ;we need to borrow 1 bit (screen is 320 pixels > 255)
                ;ora #%1000000   ;which is the last bit
                ;sta $d011
                jmp $ea81       ;return to kernel interrupt routine

clear_screen    lda #$20
clear_loop      sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $0700,x
                dex
                bne clear_loop
                rts
print_logo      lda #$0a
                sta $d022
                lda #$02
                sta $d023
                lda $d016
                ora #$10
                and #%11110111
                sta $d016
                ldx #$00
print_logo_loop lda #$00
                lda logo,x
                sta $04aa,x
                lda logo,x+19   ;2
                sta $04aa,x+40
                lda logo,x+38   ;3
                sta $04aa,x+80
                lda logo,x+57   ;4
                sta $04aa,x+120
                lda logo,x+76   ;5
                sta $04aa,x+160  
                lda logo,x+95   ;6
                sta $04aa,x+200
                lda logo,x+114   ;7
                sta $04aa,x+240
                inx
                cpx #$13
                bne print_logo_loop
                rts

scroll_message  ldx #$00
                stx $0450
print_loop      lda #%0001
                sta $d850,x
                txa
                adc credits_offset
                tay
                lda credits,y
                cmp #$40
                bcc goodtogo          ;THIS KINDOF MEANS GREATER THAN, NEVER FORGET!!!
                sbc #$40
goodtogo        sta $0450,x-1
                inx
                cpx #$28
                bne print_loop
                lda #21
                sta $d018
                jsr set_scroll
                lda scroll_offset
                cmp #$07              ;only offset text if we're back at the beginning
                bne check_offset
                inc credits_offset
check_offset    dec scroll_offset
                cmp #$00
                bne scrollisdone
                lda #$07
                sta scroll_offset
scrollisdone    rts

set_scroll      lda $d016
                and #%11110000
                adc scroll_offset
                and #%11110111
                sta $d016
                rts
                
setup_sprite    lda #$00
                sta $d020
                sta $d021
                lda #$03
                ;sta $d01d       ;stretch width
                sta $d017       ;stretch height
                lda #$0e        ;blue 01
                sta $d025
                lda #$01         ;white 11
                sta $d026
load_sprite     sei
                lda #$0a         ;pink 10 (spr1 color)
                sta $d027
                lda #$07         ;yello 7 (spr2 color)
                sta $d028
                lda #$03        
                sta $d015       ;enable sprite 1 & 2
                sta $d01c       ;enable multicolor
                lda #$76
                sta $d000      ;sprite1 X
                lda #$de
                sta $d002       ;sprite2 X
                rts

update_sprite   lda $d004       ;d004 gets to be sine_table index for now...
                tax             ;as we only have two sprites allocated atm
                lda sine_table,x
                adc #$60
                sta $d001
                lda $d004
                adc #$7f
                tax
                check_ground $d001,$07f8,#$d8
                lda sine_table,x
                adc #$60
                sta $d003
                lda $d004
                adc #$04
                sta $d004
                check_ground $d003,$07f9,#$da
                rts

update_logo     lda $d016
                and #%11110000
                ora #%00010000
                sta $d016
                lda $d018
                ora #$0e
                sta $d018
                ldx #$00         
                lda $d022
                adc #$01
                sta $d022
                rts

;check_ground    lda $d001,y     ;load sprite Y-pos
;                cmp #$c4      ;compare to ground
;                bne fall        ;if not on ground fall
;                jsr get_spr_index
;                adc #$d8        ;add #$80
;                sta $07f8,y     ;set to first sprite with X offset
;                rts             ;return
;fall            jsr get_spr_index
;                adc #$d9
;                sta $07f8,y
;                rts
;get_spr_index   tya             ;load x into a
;                lsr             ;shift right to divide by 2 (in order to offset sprite memory)
;                tay             ;store in X
;                asl             ;shift left to restore A
;                rts 

                incasm "data.asm"