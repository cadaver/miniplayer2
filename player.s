; Minimal feature-limited C64 music player v2
; Written by Cadaver (loorni@gmail.com) 9/2021

; Config values you need to define:
;
; Zeropage base. Need 23 consecutive ZP addresses when ZP optimization is in use
; or 2 when disabled
;
; PLAYER_ZPBASE   = $c0
;
; Zeropage optimization. Speeds up player. Zero to disable
;
; PLAYER_ZPOPT    = 1
;
; Sound effect support. Zero to disable
;
; PLAYER_SFX      = 1
;
; Music module support (SetMusicData routine). Zero to disable. When disabled,
; music should be converted with gt2mini2's bare mode switch (-b) and included
; in the same compilation unit as the playroutine. In both cases it needs to be
; page-aligned, as the player needs patterns to not cross pages.
;
; PLAYER_MODULES  = 1

        ; Defines

MUSICHEADERSIZE = 7

SONGJUMP        = 0
TRANS           = $80

VIBRATO         = $00
SLIDE           = $90
WAVEDELAY       = $91

FIX_SONGS       = $00
FIX_PATT        = $04
FIX_INS         = $08
FIX_WAVE        = $0c
FIX_WAVEADSR    = $10
FIX_PULSE       = $14
FIX_FILT        = $18
FIX_NOADD       = $80

FIX_SUB1        = $01
FIX_SUB80       = $02
FIX_SUB81       = $03

SFX_INIT        = $00
SFX_END         = $00
SFX_FREQ        = $82
SFX_FIRSTSLIDE  = $e0
SFX_SLIDE       = $100

ENDPATT         = 0
INS             = -1
DUR             = $100
C0              = 1*2+1
CS0             = 2*2+1
D0              = 3*2+1
DS0             = 4*2+1
E0              = 5*2+1
F0              = 6*2+1
FS0             = 7*2+1
G0              = 8*2+1
GS0             = 9*2+1
A0              = 10*2+1
AS0             = 11*2+1
H0              = 12*2+1
C1              = 13*2+1
CS1             = 14*2+1
D1              = 15*2+1
DS1             = 16*2+1
E1              = 17*2+1
F1              = 18*2+1
FS1             = 19*2+1
G1              = 20*2+1
GS1             = 21*2+1
A1              = 22*2+1
AS1             = 23*2+1
H1              = 24*2+1
C2              = 25*2+1
CS2             = 26*2+1
D2              = 27*2+1
DS2             = 28*2+1
E2              = 29*2+1
F2              = 30*2+1
FS2             = 31*2+1
G2              = 32*2+1
GS2             = 33*2+1
A2              = 34*2+1
AS2             = 35*2+1
H2              = 36*2+1
C3              = 37*2+1
CS3             = 38*2+1
D3              = 39*2+1
DS3             = 40*2+1
E3              = 41*2+1
F3              = 42*2+1
FS3             = 43*2+1
G3              = 44*2+1
GS3             = 45*2+1
A3              = 46*2+1
AS3             = 47*2+1
H3              = 48*2+1
C4              = 49*2+1
CS4             = 50*2+1
D4              = 51*2+1
DS4             = 52*2+1
E4              = 53*2+1
F4              = 54*2+1
FS4             = 55*2+1
G4              = 56*2+1
GS4             = 57*2+1
A4              = 58*2+1
AS4             = 59*2+1
H4              = 60*2+1
REST            = $7a
WAVEPOS         = $7b
SETWAVE         = $7c
SETAD           = $7d
SETSR           = $7e

pattPtrLo       = PLAYER_ZPBASE
pattPtrHi       = PLAYER_ZPBASE+1

        if PLAYER_ZPOPT > 0
zpChannelVars   = PLAYER_ZPBASE+2
chnCounter      = zpChannelVars+0
chnPattPtrLo    = zpChannelVars+1
chnPattPtrHi    = zpChannelVars+2
chnSongPos      = zpChannelVars+3
chnDuration     = zpChannelVars+4
chnWavePos      = zpChannelVars+5
chnWaveTime     = zpChannelVars+6
        endif

        if PLAYER_SFX > 0
chnSfxPtrLo     = chnWavePos
chnSfxTime      = chnWaveTime
        endif

        if PLAYER_MODULES > 0
        ; Set new music module to play. Address must be page-aligned.
        ; Playroutine should be disabled (negative value in PlayRoutine+1) during call.
        ;
        ; Parameters: A,X Address low,high

SetMusicData:   sta SetMusicData_HeaderLda+1
                clc
                adc #MUSICHEADERSIZE
                sta chnPattPtrLo
                stx SetMusicData_HeaderLda+2
                txa
                adc #$00
                sta chnPattPtrHi
                ldx #$00
SetMusicData_FixupLoop:
                lda fixupDestHiTbl,x
                beq SetMusicData_FixupDone
                sta pattPtrHi
                lda fixupDestLoTbl,x
                sta pattPtrLo
                lda fixupTypeTbl,x
                pha
                bmi SetMusicData_AddDone
                lsr
                lsr
                tay
SetMusicData_HeaderLda:
                lda dummyData,y
                clc
                adc chnPattPtrLo
                sta chnPattPtrLo
                bcc SetMusicData_AddDone
                inc chnPattPtrHi
SetMusicData_AddDone:
                pla
                and #$03
                tay
                lda chnPattPtrLo
                sec
                sbc fixupSubTbl,y
                ldy #$01
                sta (pattPtrLo),y
                iny
                lda chnPattPtrHi
                sbc #$00
                sta (pattPtrLo),y
                inx
                bne SetMusicData_FixupLoop
SetMusicData_FixupDone:
                sta pattPtrLo
                rts

songTbl         = dummyData
pattTblLo       = dummyData
pattTblHi       = dummyData
insAD           = dummyData
insWavePos      = dummyData
insPulsePos     = dummyData
insFiltPos      = dummyData
waveTbl         = dummyData
noteTbl         = dummyData
waveNextTbl     = dummyData
waveSRTbl       = dummyData
pulseLimitTbl   = dummyData
pulseSpdTbl     = dummyData
pulseNextTbl    = dummyData
filtLimitTbl    = dummyData
filtSpdTbl      = dummyData
filtNextTbl     = dummyData
        endif

Play_SilenceSID:lda #$00
                sta $d404
                sta $d404+7
                sta $d404+14
                rts

Play_InitOrStop:bmi Play_SilenceSID
Play_DoInit:    dex
                txa
                sta pattPtrHi
                asl
                asl
                adc pattPtrHi
                tay
Play_SongTblAccess1:
                lda songTbl,y
                iny
                sta Play_SongAccess1+1
                sta Play_SongAccess2+1
                sta Play_SongAccess3+1
                adc #$01
                sta Play_SongP1Access1+1
Play_SongTblAccess2:
                lda songTbl,y
                iny
                sta Play_SongAccess1+2
                sta Play_SongAccess2+2
                sta Play_SongAccess3+2
                adc #$00
                sta Play_SongP1Access1+2
                lda #$0f
                sta $d418
                ldx #$00
                stx PlayRoutine+1
                stx $d415
                stx $d417
                stx Play_FiltPos+1
                jsr Play_InitChn
                ldx #$07
                jsr Play_InitChn
                ldx #$0e
Play_InitChn:   lda #$00
        if PLAYER_SFX > 0
                cmp chnSfxPtrHi,x               ;If sound ongoing, skip wave init
                bne Play_InitChnSkipWave
        endif
                sta $d406,x
                sta $d404,x                     ;Full HR to get slow attack notes to start from zero
Play_InitChnSkipWave:
                sta chnWavePos,x
                sta chnPulsePos,x
                sta chnCounter,x
Play_SongTblAccess3:
                lda songTbl,y
                iny
                sta chnSongPos,x
                lda #<(PlayRoutine+1)           ;Point to a location guaranteed to be zero
                sta chnPattPtrLo,x              ;to enable first pattern fetch
                lda #>(PlayRoutine+1)
                sta chnPattPtrHi,x
                rts

        ; Playroutine entrypoint. Call each frame
        ;
        ; PlayRoutine+1 is the command byte.
        ; $00       Playback ongoing
        ; $01-      Init subtune
        ; $80-$ff   Silence output, e.g. during loading or SetMusicData

PlayRoutine:    ldx #$01
                bne Play_InitOrStop
Play_FiltPos:   ldy #$00
                beq Play_FiltDone
                bmi Play_FiltInit
Play_FiltCutoff:lda #$00
Play_FiltLimitM1Access1:
                cmp filtLimitTbl-1,y
                beq Play_FiltNext
                clc
Play_FiltSpdM1Access1:
                adc filtSpdTbl-1,y
Play_StoreCutoff:
                sta Play_FiltCutoff+1
                sta $d416

Play_FiltDone:  jsr Play_ChnExec
                ldx #$07
                jsr Play_ChnExec
                ldx #$0e
                jmp Play_ChnExec

Play_FiltSpdM81Access1:
Play_FiltInit:  lda filtSpdTbl-$81,y
                sta $d417
                and #$70
                ora #$0f
                sta $d418
Play_FiltNextM81Access1:
                lda filtNextTbl-$81,y
                sta Play_FiltPos+1
Play_FiltLimitM81Access1:
                lda filtLimitTbl-$81,y
                jmp Play_StoreCutoff

Play_FiltNextM1Access1:
Play_FiltNext:  lda filtNextTbl-1,y
                sta Play_FiltPos+1
                bcs Play_FiltDone               ;C=1 here

Play_DoSequencer:
                ldy chnSongPos,x
Play_SongAccess1:
                lda dummyData,y
                bne Play_NoSongJump
Play_SongP1Access1:
                lda dummyData+1,y
                tay
Play_SongAccess2:
                lda dummyData,y
Play_NoSongJump:bpl Play_NoTrans
                sta chnTrans,x
                iny
Play_SongAccess3:
                lda dummyData,y
Play_NoTrans:   iny
        if PLAYER_ZPOPT > 0
                sty chnSongPos,x
                tay
        else
                sta Play_PattNum+1
                tya
                sta chnSongPos,x
Play_PattNum:   ldy #$00
        endif
Play_PattTblLoM1Access1:
                lda pattTblLo-1,y
                sta chnPattPtrLo,x
Play_PattTblHiM1Access1:
                lda pattTblHi-1,y
                sta chnPattPtrHi,x
        if PLAYER_SFX > 0
                lda chnSfxPtrHi,x
                bne Play_JumpToSfx
        endif
                jmp Play_WaveExec
        if PLAYER_SFX > 0
Play_JumpToSfx: jmp Play_SfxExec
        endif

Play_SetWavePosCmd:
                lda (pattPtrLo),y
        if PLAYER_ZPOPT > 0
                iny
                sty chnPattPtrLo,x
                jmp Play_NewWavePosCommon
        else
                sta chnWavePos,x
                iny
                tya
                sta chnPattPtrLo,x
                jmp Play_NewWavePosCommon2
        endif

Play_Commands:  beq Play_Rest
                cmp #WAVEPOS
                beq Play_SetWavePosCmd
Play_SetRegCmd: and #$07
                sta Play_SetRegSta+1
                lda (pattPtrLo),y
                iny
Play_SetRegSta: sta $d400,x
Play_Rest:
        if PLAYER_ZPOPT > 0
                sty chnPattPtrLo,x
        else
                tya
                sta chnPattPtrLo,x
        endif
                jmp Play_WaveExec

Play_NoNewIns:  adc chnTrans,x
                sta chnNote,x
                bne Play_NewNoteCommon

        if PLAYER_SFX > 0
Play_JumpToNewNoteSfx:
                jmp Play_NewNoteSfxExec
        endif

Play_ChnExec:   inc chnCounter,x
                bmi Play_NoNewNotes
Play_NewNotes:  ldy chnPattPtrLo,x
                lda chnPattPtrHi,x
                sta pattPtrHi
                lda (pattPtrLo),y
                beq Play_DoSequencer
                bmi Play_NewDur
                lda chnDuration,x
                bmi Play_DurCommon
Play_NewDur:    iny
                sta chnDuration,x
Play_DurCommon: sta chnCounter,x
        if PLAYER_SFX > 0
                lda chnSfxPtrHi,x
                bne Play_JumpToNewNoteSfx
        endif
                lda (pattPtrLo),y
                iny
                cmp #REST
                bcs Play_Commands
                lsr
                bcs Play_NoNewIns
                adc chnTrans,x
                sta chnNote,x
                lda (pattPtrLo),y
                iny
                sta chnIns,x
Play_NewNoteCommon:
        if PLAYER_ZPOPT > 0
                sty chnPattPtrLo,x
        else
                tya
                sta chnPattPtrLo,x
        endif
                ldy chnIns,x
                bmi Play_LegatoNoteInit
Play_InsPulsePosAccess1:
                lda insPulsePos,y
                beq Play_SkipPulseInit
                sta chnPulsePos,x
Play_SkipPulseInit:
Play_InsFiltPosAccess1:
                lda insFiltPos,y
                beq Play_SkipFiltInit
                sta Play_FiltPos+1
Play_SkipFiltInit:
                lda #$0f
                sta $d406,x
                lda #$08
                sta $d404,x
Play_InsADAccess1:
                lda insAD,y
                sta $d405,x
Play_InsWavePosAccess1:
                lda insWavePos,y
Play_NewWavePosCommon:
                sta chnWavePos,x
Play_NewWavePosCommon2:
                lda #$00
                sta chnWaveTime,x
Play_WaveDone:  rts

Play_LegatoNoteInit:
Play_InsWavePosM80Access1:
                lda insWavePos-$80,y
                bne Play_NewWavePosCommon

        if PLAYER_SFX > 0
Play_NoNewNotesJumpToSfx:
                jmp Play_SfxExec
        endif

Play_NoNewNotes:
        if PLAYER_SFX > 0
                lda chnSfxPtrHi,x
                bne Play_NoNewNotesJumpToSfx
        endif
Play_PulseExec: ldy chnPulsePos,x
                bmi Play_PulseInit
                beq Play_WaveExec
Play_PulseMod:  lda chnPulse,x
Play_PulseLimitM1Access1:
                cmp pulseLimitTbl-1,y
                beq Play_PulseNext
                clc
Play_PulseSpdM1Access1:
                adc pulseSpdTbl-1,y
                adc #$00
Play_StorePulse:sta chnPulse,x
                sta $d402,x
                sta $d403,x
Play_WaveExec:  ldy chnWavePos,x
                beq Play_WaveDone
Play_WaveM1Access1:
                lda waveTbl-1,y
                beq Play_Vibrato
                cmp #SLIDE
                bcs Play_SlideOrDelay
Play_WaveChange:sta $d404,x
Play_WaveSRM1Access1:
                lda waveSRTbl-1,y
                beq Play_SkipADSR
                sta $d406,x
Play_SkipADSR:
Play_NoWaveChange:
Play_WaveNextM1Access1:
                lda waveNextTbl-1,y
                sta chnWavePos,x
Play_NoteM1Access1:
                lda noteTbl-1,y
                bmi Play_WaveStepAbsNote
Play_WaveStepRelNote:
                clc
                adc chnNote,x
Play_WaveStepAbsNote:
                asl
                tay
                lda freqTbl-2,y
                sta chnFreqLo,x
                sta $d400,x
                lda freqTbl-1,y
Play_StoreFreqHi:
                sta chnFreqHi,x
                sta $d401,x
                rts

Play_PulseNextM81Access1:
Play_PulseInit: lda pulseNextTbl-$81,y
                sta chnPulsePos,x
Play_PulseLimitM81Access1:
                lda pulseLimitTbl-$81,y
                jmp Play_StorePulse

Play_PulseNextM1Access1:
Play_PulseNext: lda pulseNextTbl-1,y
                sta chnPulsePos,x
                bcs Play_WaveExec

Play_SlideOrDelay:
                beq Play_Slide
Play_WaveDelay: adc chnWaveTime,x
                bne Play_WaveDelayNotOver
                sta chnWaveTime,x
                jmp Play_NoWaveChange
Play_WaveDelayNotOver:
                inc chnWaveTime,x
Play_VibDone:   rts

Play_Vibrato:   lda chnWaveTime,x
                bpl Play_VibNoDir
Play_NoteM1Access2:
                cmp noteTbl-1,y
                bcs Play_VibNoDir2
                eor #$ff
Play_VibNoDir:  sec
Play_VibNoDir2: sbc #$02
                sta chnWaveTime,x
                lsr
                lda chnFreqLo,x
                bcs Play_VibDown
Play_WaveNextM1Access2:
Play_VibUp:     adc waveNextTbl-1,y
                sta chnFreqLo,x
                sta $d400,x
                bcc Play_VibDone
                lda chnFreqHi,x
                adc #$00
                jmp Play_StoreFreqHi
Play_WaveNextM1Access3:
Play_VibDown:   sbc waveNextTbl-1,y
                sta chnFreqLo,x
                sta $d400,x
                bcs Play_VibDone
                lda chnFreqHi,x
                sbc #$00
                jmp Play_StoreFreqHi

Play_Slide:     lda chnFreqLo,x
Play_NoteM1Access3:
                adc noteTbl-1,y                 ;Note: speed must be stored as speed-1 due to C=1 here
                sta chnFreqLo,x
                sta $d400,x
                lda chnFreqHi,x
Play_WaveNextM1Access4:
                adc waveNextTbl-1,y
                jmp Play_StoreFreqHi

        if PLAYER_SFX > 0
Play_NewNoteSfxNoNewIns:
                adc chnTrans,x
                sta chnNote,x
                bne Play_NewNoteSfxRest
Play_NewNoteSfxExec:
                lda (pattPtrLo),y               ;Fetch new notes and new instrument, but do not execute SID register changes
                iny
                cmp #REST
                beq Play_NewNoteSfxRest
                bcs Play_NewNoteSfxCommand
                lsr
                bcs Play_NewNoteSfxNoNewIns
                adc chnTrans,x
                sta chnNote,x
                lda (pattPtrLo),y
                sta chnIns,x
Play_NewNoteSfxCommand:
                iny
Play_NewNoteSfxRest:
        if PLAYER_ZPOPT > 0
                sty chnPattPtrLo,x
        else
                tya
                sta chnPattPtrLo,x
        endif
                lda chnSfxPtrHi,x
Play_SfxExec:   sta pattPtrHi
                ldy chnSfxPtrLo,x
                lda (pattPtrLo),y
                beq Play_SfxEnd
                cmp #$10
                bcc Play_SfxInit
                cmp #SFX_FREQ
                bcs Play_SfxFreqOrSlide
                iny
                sta $d404,x
                lda chnSfxSR,x
                sta $d406,x
                lda (pattPtrLo),y
                cmp #SFX_FREQ
                bcc Play_SfxStepDone
        if PLAYER_ZPOPT > 0
                sty chnSfxPtrLo,x
        else
                sta Play_SfxRestA+1
                tya
                sta chnSfxPtrLo,x
Play_SfxRestA:  lda #$00
        endif
Play_SfxFreqOrSlide:
                cmp #SFX_FIRSTSLIDE
                bcs Play_SfxSlide
Play_SfxFreq:   iny
        if PLAYER_ZPOPT > 0
                sty chnSfxPtrLo,x
        else
                sta Play_SfxRestA2+1
                tya
                sta chnSfxPtrLo,x
Play_SfxRestA2: lda #$00
        endif
                sbc #SFX_FREQ-2
                jmp Play_WaveStepAbsNote
Play_SfxSlide:  iny
                dec chnSfxTime,x
                sbc chnSfxTime,x
                bcc Play_SfxSlideNotDone
                sta chnSfxTime,x
                tya
                adc #$01-1                  ;C=1, becomes 0
                sta chnSfxPtrLo,x
Play_SfxSlideNotDone:
                lda (pattPtrLo),y
                beq Play_SfxSlideNoOp
                tay
                lda chnFreqLo,x
                adc sfxSlideTblLo-1,y
                sta chnFreqLo,x
                sta $d400,x
                lda chnFreqHi,x
                adc sfxSlideTblHi-1,y
                jmp Play_StoreFreqHi

Play_SfxEnd:    sta chnWavePos,x
                sta chnPulsePos,x
                sta chnSfxPtrHi,x
Play_SfxSlideNoOp:
                rts

Play_SfxInit:   sta $d402,x
                sta $d403,x
                lda #$08
                sta $d404,x
                lda #$0f
                sta $d406,x
                iny
                lda (pattPtrLo),y
                iny
                sta $d405,x
                lda (pattPtrLo),y
                iny
                sta chnSfxSR,x
                lda #$00
                sta chnSfxTime,x
Play_SfxStepDone:
        if PLAYER_ZPOPT > 0
                sty chnSfxPtrLo,x
        else
                tya
                sta chnSfxPtrLo,x
        endif
                rts
        endif

        ; Fixup data for SetMusicData

        if PLAYER_MODULES > 0
fixupSubTbl:    dc.b 0,1,$80,$81

fixupDestLoTbl: dc.b <Play_SongTblAccess1
                dc.b <Play_SongTblAccess2
                dc.b <Play_SongTblAccess3
                dc.b <Play_PattTblLoM1Access1
                dc.b <Play_PattTblHiM1Access1
                dc.b <Play_InsADAccess1
                dc.b <Play_InsWavePosAccess1
                dc.b <Play_InsWavePosM80Access1
                dc.b <Play_InsPulsePosAccess1
                dc.b <Play_InsFiltPosAccess1
                dc.b <Play_WaveM1Access1
                dc.b <Play_NoteM1Access1
                dc.b <Play_NoteM1Access2
                dc.b <Play_NoteM1Access3
                dc.b <Play_WaveNextM1Access1
                dc.b <Play_WaveNextM1Access2
                dc.b <Play_WaveNextM1Access3
                dc.b <Play_WaveNextM1Access4
                dc.b <Play_WaveSRM1Access1
                dc.b <Play_PulseLimitM1Access1
                dc.b <Play_PulseLimitM81Access1
                dc.b <Play_PulseSpdM1Access1
                dc.b <Play_PulseNextM1Access1
                dc.b <Play_PulseNextM81Access1
                dc.b <Play_FiltLimitM1Access1
                dc.b <Play_FiltLimitM81Access1
                dc.b <Play_FiltSpdM1Access1
                dc.b <Play_FiltSpdM81Access1
                dc.b <Play_FiltNextM1Access1
                dc.b <Play_FiltNextM81Access1

fixupDestHiTbl: dc.b >Play_SongTblAccess1
                dc.b >Play_SongTblAccess2
                dc.b >Play_SongTblAccess3
                dc.b >Play_PattTblLoM1Access1
                dc.b >Play_PattTblHiM1Access1
                dc.b >Play_InsADAccess1
                dc.b >Play_InsWavePosAccess1
                dc.b >Play_InsWavePosM80Access1
                dc.b >Play_InsPulsePosAccess1
                dc.b >Play_InsFiltPosAccess1
                dc.b >Play_WaveM1Access1
                dc.b >Play_NoteM1Access1
                dc.b >Play_NoteM1Access2
                dc.b >Play_NoteM1Access3
                dc.b >Play_WaveNextM1Access1
                dc.b >Play_WaveNextM1Access2
                dc.b >Play_WaveNextM1Access3
                dc.b >Play_WaveNextM1Access4
                dc.b >Play_WaveSRM1Access1
                dc.b >Play_PulseLimitM1Access1
                dc.b >Play_PulseLimitM81Access1
                dc.b >Play_PulseSpdM1Access1
                dc.b >Play_PulseNextM1Access1
                dc.b >Play_PulseNextM81Access1
                dc.b >Play_FiltLimitM1Access1
                dc.b >Play_FiltLimitM81Access1
                dc.b >Play_FiltSpdM1Access1
                dc.b >Play_FiltSpdM81Access1
                dc.b >Play_FiltNextM1Access1
                dc.b >Play_FiltNextM81Access1
                dc.b 0

fixupTypeTbl:   dc.b FIX_NOADD
                dc.b FIX_NOADD
                dc.b FIX_NOADD
                dc.b FIX_SONGS|FIX_SUB1
                dc.b FIX_PATT|FIX_SUB1
                dc.b FIX_PATT
                dc.b FIX_INS
                dc.b FIX_NOADD|FIX_SUB80
                dc.b FIX_INS
                dc.b FIX_INS
                dc.b FIX_INS|FIX_SUB1
                dc.b FIX_WAVE|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB1
                dc.b FIX_WAVE|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB1
                dc.b FIX_WAVE|FIX_SUB1
                dc.v FIX_WAVEADSR|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB81
                dc.b FIX_PULSE|FIX_SUB1
                dc.b FIX_PULSE|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB81
                dc.b FIX_PULSE|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB81
                dc.b FIX_FILT|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB81
                dc.b FIX_FILT|FIX_SUB1
                dc.b FIX_NOADD|FIX_SUB81
        endif

        ; Frequency table

freqTbl:        dc.w $022d,$024e,$0271,$0296,$02be,$02e8,$0314,$0343,$0374,$03a9,$03e1,$041c
                dc.w $045a,$049c,$04e2,$052d,$057c,$05cf,$0628,$0685,$06e8,$0752,$07c1,$0837
                dc.w $08b4,$0939,$09c5,$0a5a,$0af7,$0b9e,$0c4f,$0d0a,$0dd1,$0ea3,$0f82,$106e
                dc.w $1168,$1271,$138a,$14b3,$15ee,$173c,$189e,$1a15,$1ba2,$1d46,$1f04,$20dc
                dc.w $22d0,$24e2,$2714,$2967,$2bdd,$2e79,$313c,$3429,$3744,$3a8d,$3e08,$41b8
                dc.w $45a1,$49c5,$4e28,$52cd,$57ba,$5cf1,$6278,$6853,$6e87,$751a,$7c10,$8371
                dc.w $8b42,$9389,$9c4f,$a59b,$af74,$b9e2,$c4f0,$d0a6,$dd0e,$ea33,$f820,$ffff

        ; Non-ZP variables

        if PLAYER_ZPOPT = 0
chnCounter:     dc.b 0
chnPattPtrLo:   dc.b 0
chnPattPtrHi:   dc.b 0
chnSongPos:     dc.b 0
chnDuration:    dc.b 0
chnWavePos:     dc.b 0
chnWaveTime:    dc.b 0

                dc.b 0,0,0,0,0,0,0
                dc.b 0,0,0,0,0,0,0
        endif

chnTrans:       dc.b 0
chnIns:         dc.b 0
chnNote:        dc.b 0
chnFreqLo:      dc.b 0
chnFreqHi:      dc.b 0
chnPulsePos:    dc.b 0
chnPulse:       dc.b 0

                dc.b 0,0,0,0,0,0,0
                dc.b 0,0,0,0,0,0,0

        if PLAYER_SFX > 0
chnSfxPtrHi:    dc.b 0
chnSfxSR:       dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0

                dc.b 0,0,0,0,0,0,0
                dc.b 0,0,0,0,0,0,0
        endif

dummyData:

