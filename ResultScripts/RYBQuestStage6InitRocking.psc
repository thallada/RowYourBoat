; RYB Stage 6 Initialize Rocking

set RYB.RockingEnabled to 1
set RYB.RockAmplitudeZ to 0.8
set RYB.RockMaxAbsoluteZ to 3.0
set RYB.RockAmplitudePitch to 2.0
set RYB.RockAmplitudeRoll to 3.0
set RYB.RockFrequency to 30.0
set RYB.RockFrequency2 to 45.0
set RYB.RockFrequency3 to 25.0
set RYB.RockRandomInterval to 3.0
set RYB.RockSpeedFactor to 0.25
set RYB.RockDistanceThreshold to 3000
set RYB.RockSmoothingFactor to 0.1
set RYB.RockWeatherFactor to 0.5
set RYB.RockPhase to GetRandomPercent * 3.6
set RYB.RockPhase2 to GetRandomPercent * 3.6
set RYB.RockPhase3 to GetRandomPercent * 3.6
set RYB.RockRandomPhase to (GetRandomPercent - 50) * 0.02