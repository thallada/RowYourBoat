; RYB Stage 3 Initialize Collider

set RYB.Collider to RYBColliderRef
set RYB.ColliderOffset to 300
set RYB.ColliderOffsetReverse to 350
set RYB.ColliderMoveFreq to 0.05
set RYB.ColliderZ to 1
RYBColliderRef.SetActorAlpha 0.0
RYBColliderRef.SetActorRefraction 10.0
RYBColliderRef.AddSpell MG14JskarInvis
RYBColliderRef.SetActorValue Aggression 0
RYBColliderRef.SetActorValue Blindness 100
RYBColliderRef.ModActorValue Sneak 0
RYBColliderRef.SetActorsAI 0
RYBColliderRef.SetDestroyed 1
set RYB.CollisionDetectDelay to 2
set RYB.CollisionDetectZThreshold to 10