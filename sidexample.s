; .sid example of using the playroutine. Music and player are assembled in the
; same file, but page-alignment of the music data must be ensured.

                processor 6502
                org $0000

SUBTUNES        = 1

                dc.b "PSID"
                dc.b 0,2
                dc.b 0,$7c
                dc.b $00,$00
                dc.b >Init,<Init
                dc.b >PlayRoutine,<PlayRoutine
                dc.b 0,SUBTUNES
                dc.b 0,1
                dc.b 0,0,0,0

                org $0016
                dc.b "Miniplayer2 test"

                org $0036
                dc.b "Cadaver"

                org $0056

                dc.b "2023 Covert Bitops"

                org $0076
                dc.b $00,$10

                org $007c
                dc.b $00,$10
                rorg $1000

        ; Music data, must page-align

musicdata:      include "musicdata.s"

        ; Player configuration

PLAYER_ZPBASE   = $20
PLAYER_ZPOPT    = 1
PLAYER_SFX      = 0
PLAYER_MODULES  = 0

        ; Player

                include "player.s"

        ; Init routine

Init:           tax
                inx
                stx PlayRoutine+1
                rts
