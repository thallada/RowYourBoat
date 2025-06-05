; RYB Quest Stage 18 Player Yaw Angle Trigonometry (sin/cos approximation)

; Script originally by Galsiah.
; See: https://cs.uesp.net/wiki/Trigonometry_Functions#Galsiah_Version
set RYB.ang to (RYB.ang * RYB.degToRad)
set RYB.n to 1
if (RYB.ang > 4.7123)
    set RYB.ang to (RYB.ang - 6.2832)
elseif (RYB.ang > 1.5708)
    set RYB.ang to (RYB.ang - 3.1416)
    set RYB.n to -1
endif
set RYB.t2 to (RYB.ang * RYB.ang)
set RYB.PlayerSin to RYB.n*(RYB.ang*(1 - RYB.t2*0.16605 + 0.00761*RYB.t2*RYB.t2))
set RYB.PlayerCos to RYB.n*(1 - RYB.t2*0.4967 + 0.03705*RYB.t2*RYB.t2)