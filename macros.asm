defm    check_ground ;1=pos addr, 2=sprite addr, 3=base spr
                lda /1
                clc
                cmp #$c3
                bne @fall
                lda #/3
                jmp @store
@fall           lda #/3
                clc
                adc #$01
@store          sta /2
        endm