; RYB Stage 21 Collider Collision

set RYB.BaseBoatVelocity to 0
set RYB.CurrentTurnRate to 0
set RYB.BoatMoving to 0
set RYB.AutoRowing to 0
set RYB.Rowing to 0
RYBColliderRef.Disable
RYBSeatRef.SetDestroyed 0
RYBBoatMapMarker.Enable
set RYB.CollisionDetectTimer to RYB.CollisionDetectDelay
if (RYB.BaseBoatVelocity > (RYB.BoatMaxVelocity * 0.9) || RYB.BaseBoatVelocity < -(RYB.BoatMaxVelocity * 0.9))
    RYBBoatRef.PlaySound3D TRPImpactStone
else
    RYBBoatRef.PlaySound3D TRPMineExplode
endif
set RYB.Grounded to 1
Message "The boat has grounded."