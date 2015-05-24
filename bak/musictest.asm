             * = $0810 ;Remember SYS 2064 to enable it
             sei
             lda #<irq
             ldx #>irq
             sta $314
             stx $315
             lda #$1b
             ldx #$00
             ldy #$7f 
             sta $d011
             stx $d012
             sty $dc0d
             lda #$01
             sta $d01a
             sta $d019 ; ACK any raster IRQs
             lda #$00
             jsr $7580 ;Initialize Richard's music
             cli
hold         jmp hold ;We don't want to do anything else here. :)
                      ; we could also RTS here, when also changing $ea81 to $ea31
irq
             lda #$01
             sta $d019 ; ACK any raster IRQs
             jsr $7587 ;Play the music
             jmp $ea31
            

             * = $7580
                incbin "Alien_Souls.sid"