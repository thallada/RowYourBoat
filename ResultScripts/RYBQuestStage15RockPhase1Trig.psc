; RYB Quest Stage 15 Rocking Phase 1 (Primary) Angle Trigonometry (sin/cos approximation)

; Script originally by Galsiah.
; See: https://cs.uesp.net/wiki/Trigonometry_Functions#Galsiah_Version
set RYB.rockAng to RYB.RockPhase * RYB.degToRad
set RYB.rockN to 1
if (RYB.rockAng > 4.7123)
    set RYB.rockAng to (RYB.rockAng - 6.2832)
elseif (RYB.rockAng > 1.5708)
    set RYB.rockAng to (RYB.rockAng - 3.1416)
    set RYB.rockN to -1
endif
set RYB.rockT2 to (RYB.rockAng * RYB.rockAng)
set RYB.rockSin to RYB.rockN * (RYB.rockAng * (1 - RYB.rockT2 * 0.16605 + 0.00761 * RYB.rockT2 * RYB.rockT2))