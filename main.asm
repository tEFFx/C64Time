                *=$2000
                incbin "finn.spt",1,2,true
                *=$2080
                incbin "jake.spt",1,2,true
                *=$3800
                incbin "logo.cst",0,196

                *=$1000
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
                lda #<irq
                ldx #>irq       ;get pointer to irq routine
                sta $314        ;store low addr
                stx $315        ;store hi addr
                lda #$00        ;trigger interrupt @ row 0 (of screen)
                sta $d012
                lda $d011       ;we need to borrow 1 bit (screen is 320 pixels > 255)
                and #$7f        ;which is the first bit
                sta $d011
                cli             ;clear interrupt flag
                jmp *           ;loop until the end of time

irq             dec $d019       ;tell irq HEY! im here and everything is fiiiiine
                jsr update_sprite
                jsr update_logo
                jmp $ea81       ;return to kernel interrupt routine

clear_screen    lda #$20
clear_loop      sta $0400,x
                sta $0500,x
                sta $0600,x
                sta $0700,x
                dex
                bne clear_loop
                rts

print_logo      lda $d018
                ora #$0e
                sta $d018
                lda #$0a
                sta $d022
                lda #$02
                sta $d023
                lda $d016
                ora #$10
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
                
setup_sprite    lda #$00
                sta $d020
                lda #$06
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
                lda #$80
                sta $07f8       ;set sprite1 to $2000 (40 * 80 = 2000 HEX)
                lda #$82
                sta $07f9       ;set sprite2 to $2040
                lda #$03        
                sta $d015       ;enable sprite 1 & 2
                sta $d01c       ;enable multicolor
                lda #$80
                sta $d000      ;sprite1 X
                lda #$d4
                sta $d002       ;sprite2 X
                lda #$20
                rts

update_sprite   lda $d004       ;d004 gets to be sine_table index for now...
                tax             ;as we only have two sprites allocated atm
                lda sine_table,x
                adc #$60
                sta $d001
                lda $d004
                adc #$7f
                tax
                lda sine_table,x
                adc #$60
                sta $d003
                lda $d004
                adc #$04
                sta $d004
                ldy #$00
                jsr check_ground
                ldy #$02
                jsr check_ground
                cpx #$ff
                rts

update_logo     ldx #$00         
                lda $d022
                adc #$01
                sta $d022
                rts

check_ground    lda $d001,y     ;load sprite Y-pos
                cmp #$c4      ;compare to ground
                bne fall        ;if not on ground fall
                jsr get_spr_index
                adc #$80        ;add #$80
                sta $07f8,y     ;set to first sprite with X offset
                rts             ;return
fall            jsr get_spr_index
                adc #$81
                sta $07f8,y
                rts
get_spr_index   tya             ;load x into a
                lsr             ;shift right to divide by 2 (in order to offset sprite memory)
                tay             ;store in X
                asl             ;shift left to restore A
                rts 

logo            BYTE    $00,$01,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                BYTE    $03,$04,$05,$09,$0D,$0E,$0F,$10,$16,$17,$18,$19,$1E,$1F,$02,$21,$26,$27,$28
                BYTE    $06,$07,$08,$0C,$11,$12,$13,$14,$1A,$1B,$1C,$1D,$22,$23,$24,$25,$29,$2A,$1A
                BYTE    $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
                BYTE    $20,$20,$20,$20,$2B,$2C,$2D,$2E,$32,$33,$34,$35,$3E,$3F,$40,$20,$20,$20,$20
                BYTE    $20,$20,$20,$20,$20,$2F,$20,$2F,$36,$37,$38,$39,$36,$41,$20,$20,$20,$20,$20
                BYTE    $20,$20,$20,$20,$20,$30,$20,$31,$3A,$3B,$3C,$3D,$42,$43,$44,$20,$20,$20,$20
sine_table      byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,99,99,99,99,99,99,99
                byte 99,98,96,95,94,92,91,89
                byte 88,86,85,83,82,80,79,77
                byte 76,74,73,71,70,68,66,65
                byte 63,62,60,58,57,55,54,52
                byte 51,49,48,46,45,43,42,40
                byte 39,37,36,34,33,32,30,29
                byte 28,26,25,24,23,21,20,19
                byte 18,17,16,15,14,13,12,11
                byte 10,9,9,8,7,6,6,5
                byte 4,4,3,3,2,2,2,1
                byte 1,1,1,0,0,0,0,0
                byte 0,0,0,0,0,1,1,1
                byte 1,2,2,3,3,4,4,5
                byte 5,6,7,7,8,9,10,11
                byte 12,12,13,14,15,16,18,19
                byte 20,21,22,23,24,26,27,28
                byte 30,31,32,34,35,37,38,39
                byte 41,42,44,45,47,48,50,51
                byte 53,55,56,58,59,61,62,64
                byte 64,66,67,69,70,72,73,75
                byte 77,78,80,81,83,84,86,87
                byte 89,90,91,93,94,96,97,98        