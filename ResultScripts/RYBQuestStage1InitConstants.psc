; RYB Stage 1 Initialize Constants

set RYB.ModVersion to 0.2
set RYB.pi to 3.1415927
set RYB.halfPi to RYB.pi / 2
set RYB.radToDeg to 180.0/RYB.pi ; always multiply to convert
set RYB.degToRad to 1/RYB.radToDeg
set RYB.TargetDeltaTime to 0.0166
set RYB.DeltaSmoothingFactor to 0.1
set RYB.BoatMaxVelocity to 6.0
set RYB.VelocityDecayLnRetentionFactor to -0.01005 ; approx. natural log of the retention factor of 0.99
set RYB.BaseTurnRate to 0.4
set RYB.BaseRowForce to 0.05
set RYB.TurnDeadzone to 10
set RYB.RowSpellDuration to 1.5
set RYB.OverboardDistance to 300
set RYB.TurnRateAcceleration to 0.15
set RYB.TurnRateDeceleration to 0.92
set RYB.LandZThreshold to 10
set RYB.WaterLevelZ to 0
set RYB.HighUpdateRate to 0.0166
set RYB.MediumUpdateRate to 0.1
set RYB.LowUpdateRate to 0.5