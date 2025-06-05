; RYB Stage 10 DragTargetAngle atan2

; atan2 approximation in radians from https://math.stackexchange.com/a/1105038
if (RYB.dXAbs >= RYB.dYAbs)
    set RYB.a to RYB.dYAbs / RYB.dXAbs
else
    set RYB.a to RYB.dXAbs / RYB.dYAbs
endif
set RYB.s to RYB.a * RYB.a
set RYB.r to ((-0.0464964749 * RYB.s + 0.15931422) * RYB.s - 0.327622764) * RYB.s * RYB.a + RYB.a
if (RYB.dYAbs > RYB.dXAbs)
    set RYB.r to RYB.halfPi - RYB.r
endif
if (RYB.dX < 0)
    set RYB.r to RYB.pi - RYB.r
endif
if (RYB.dY < 0)
    set RYB.r to -RYB.r
endif
set RYB.DragTargetAngle to RYB.r * RYB.radToDeg ; radians→deg
; convert mathematical angle → Oblivion heading: heading = (90 – angle) mod 360
set RYB.DragTargetAngle to 90.0 - RYB.DragTargetAngle
if (RYB.DragTargetAngle < 0)
    set RYB.DragTargetAngle to RYB.DragTargetAngle + 360
endif