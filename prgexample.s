; .prg example of using the playroutine. Press fire to trigger a sound effect.

                processor 6502
                org $0801

Sys:            dc.b $0b,$08
                dc.b $0a,$00
                dc.b $9e
                dc.b $32,$30,$36,$31
                dc.b $00,$00,$00

Start:          sei
                lda #$00
                sta $d415
                lda #$7f
                sta $dc0d
                lda #$33
                sta $d012
                lda #$01
                sta $d01a
                lda #<Raster
                sta $0314
                lda #>Raster
                sta $0315
                lda #27
                sta $d011
                lda $dc0d
                dec $d019
                lda #<musicModule
                ldx #>musicModule
                jsr SetMusicData
                cli
Loop:           lda #68
                sta $0400
                sta $0428
                sta $0450
                ldx curRaster
                lda hexChars,x
                sta $400+37
                lda #"/"
                sta $400+38
                ldx maxRaster
                lda hexChars,x
                sta $400+39
                jmp Loop

        ; Player configuration

PLAYER_ZPBASE   = $20
PLAYER_SFX      = 1
PLAYER_MODULES  = 1

        ; Player

                include "player.s"

        ; Raster interrupt code

Raster:         cld
                lda $d019
                sta $d019
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                inc $d020
                jsr PlayRoutine
                lda $d012
                ldx #$0e
                stx $d020
                sec
                sbc #$34
                sta curRaster
                cmp maxRaster
                bcc RasterNoNewMax
                sta maxRaster
RasterNoNewMax: lda $dc00
                pha
                and #$10
                bne RasterNoFire
                lda prevJoy
                and #$10
                beq RasterNoFire
                lda #<soundEffect   ;Play effect on channel 3 (channel var index 14)
                sta chnSfxPtrLo+14
                lda #>soundEffect
                sta chnSfxPtrHi+14
RasterNoFire:   pla
                sta prevJoy
                jmp $ea31

hexChars:       dc.b $30,$31,$32,$33,$34,$35,$36,$37,$38,$39
                dc.b $01,$02,$03,$04,$05,$06

curRaster:      dc.b 0
maxRaster:      dc.b 0
prevJoy:        dc.b 0

        ; SFX data. Individual sound effects must not pagecross

                org $0f00

soundEffect:    dc.b SFX_INIT+$01,$04,$e9           ;Init with pulsewidth 1 and ADSR 04e9
                dc.b $81,SFX_FREQ+$3c,SFX_FREQ+$30
                dc.b SFX_SLIDE-4,$01                ;Start a slide down
                dc.b $80                            ;Gate off
                dc.b SFX_SLIDE-16,$01               ;Continue the slide
                dc.b SFX_END                        ;End effect

        ; Slide speed table is required when using sound effects.
        ; Values are 16bit, the first table index is 1 and 0 is a zero speed slide (delay)

sfxSlideTblLo:  dc.b <(-200)
sfxSlideTblHi:  dc.b >(-200)

        ; Music module (assembled separately), must be page-aligned

                org $1000

musicModule:    incbin "musicmodule.bin"