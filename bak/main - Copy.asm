                *=$2000
                incbin "finn.spt",1,1,true
                *=$2040
                incbin "jake.spt",1,1,true

setup_sprite    *=$1000
                lda #$00
                sta $d020
                sta $d021
                lda #$03
                sta $d01d       ;stretch width
                sta $d017       ;stretch height
                lda #$09        ;black 01
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
                lda #$81
                sta $07f9       ;set sprite2 to $2040
                lda #$03        
                sta $d015       ;enable sprite 1 & 2
                sta $d01c       ;enable multicolor
                lda #$40
                sta $d000      ;sprite1 X
                lda #$fa
                sta $d002       ;sprite2 X

init_loop       lda #$40
down_loopy      ldx #$00
down_loopx      ldy #$00 
down_loop       iny
                cpy #$47
                bne down_loop
                inx
                cpx #$47
                bne down_loopx
                clc
                adc #$01
                sta $d001       ;sprite1 Y
                sta $d003       ;sprite2 Y
                cmp #$a0
                bne down_loopy
up_loopy        ldx #$00
up_loopx        ldy #$00 
up_loop         iny
                cpy #$47
                bne up_loop
                inx
                cpx #$47
                bne up_loopx
                clc
                sbc #$01
                sta $d001       ;sprite1 Y
                sta $d003       ;sprite2 Y
                cmp #$40
                bne up_loopy
                jmp down_loopy
        