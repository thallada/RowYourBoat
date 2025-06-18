ScriptName RYBQuestScript

float fQuestDelayTime ; controls script update rate, see: https://cs.uesp.net/wiki/FQuestDelayTime
float HighUpdateRate ; script updates per second when boat is moving or rocking (default: 0.0166)
float MediumUpdateRate ; script updates per second when boat is not moving or rocking but nearby (default: 0.1)
float LowUpdateRate ; script updates per second when far away from the boat (default: 1.0)

float ModVersion ; For handling updates

; Quest script states
short Initializing

; Boat states
short BoatMoving ; 0 = not moving, 1 = about to move this tick, 2 = in motion
short Rowing ; 0 = not rowing (timed), 1 = rowing forward (timed), 2 = rowing backward (timed)
short AutoRowing ; 0 = not auto rowing, 1 = auto rowing forward, 2 = auto rowing backward
; 1 = run positioning code once relative to player
; 2 = run positioning code once relative to boat
; -1 = re-enable boat and attachments, then run positioning code once relative to player
short Resetting
short LockHeading ; 0 = free to turn, 1 = locked to current boat heading
short LadderDeployed ; 0 = disabled, 1 = enabled
short LampOn
; 0 = not summoning, 1 = waiting for collider to move, 2 = moving boat to collider,
; 3 = moving slightly to fix collision/interaction issues
short Summoning
short Dragging ; 0 = not dragging, 1 = dragging
short Grounded ; 0 = not grounded, 1 = collided with something and stopped
short OnLand ; 0 = not on land, 1 = on land (Z position is too high) auto-set if BoatZ > LandZThreshold
short BoatPurchased
short ChestPurchased
short LampPurchased
short LadderPurchased
short PlayerNearBoat ; 0 = not near boat, 1 = near boat (within RockDistanceThreshold)

; Triggers
; Sort of like functions that any script can call by setting these to 1 which this script will handle and set back to 0
short TriggerAutoRow ; 1 = auto-row forward, 2 = auto-row backward
short TriggerGetOnBoat ; 1 = get on boat via SetPosition, 2 = sit on the seat
short TriggerStartDragging ; 1 = will start dragging if Dragging == 0
short TriggerStopDragging ; 1 = will stop dragging if Dragging == 1
short TriggerSummonBoat ; 1 = summon boat, 2 = place boat right here
short TriggerRowCast ; player casting the row spell will set this to 1 (forward) or 2 (back)

float SecondsPassed ; actual time passed since last frame (GetSecondsPassed)
float SmoothedDeltaTime ; SecondsPassed adjusted to the recent average frame rate using exponentially smoothing
; How much to smooth the delta time.
; Tune this between 0.05-0.2 to make adjustments more/less responsive to frame rate changes (default: 0.1)
float DeltaSmoothingFactor
float TargetDeltaTime ; target delta time to smooth to (default: 0.0166) aka. 60fps

; All "base" speed/rate values below assume a frame rate of 60fps (0.0166 seconds per frame)
; To prevent the boat from moving faster in higher FPS and slower in lower FPS, the speed values are dynamically
; adjusted to the current frame rate (based on the result of GetSecondsPassed exponentially smoothed over many frames).
float BaseBoatVelocity ; distance in units to move the boat every frame
float AbsoluteBoatVelocity ; absolute value of BaseBoatVelocity (used in calculating the turn rate)
float FrameBoatVelocity
float BoatMaxVelocity ; maximum distance in units to move the boat every frame (default: 6)
float VelocityDecayLnRetentionFactor ; natural log of the retention factor (0.99) per frame at 60fps (default: -0.01005)
float FrameVelocityDecay ; how much to multiply the velocity by every frame to decay it. will be calculated
float BaseRowForce ; how much to increase/decrease the velocity every frame when rowing (default: 0.05)
float FrameRowForce
float BaseTurnRate ; how much to turn the boat every frame (default: 0.4)
float TurnRateVelocityFactor ; how much to multiply the base turn rate by based on the boat's velocity (calculated)
float FrameTurnRate
float CurrentTurnRate ; the actual turn rate being applied this frame (decayed or accelerated version of FrameTurnRate)
float TurnRateAcceleration ; how quickly turn rate ramps up (default: 0.15)
float TurnRateDeceleration ; how quickly turn rate decays when not turning (default: 0.92)
float LandZThreshold ; Z position that the boat must be above to be considered on land (default: 10)
float WaterLevelZ ; Z position of the water level (default: 0)

float RowTimer ; current time left before stopping rowing
float RowSpellDuration ; duration to row after spell is cast (default: 1.0)
float OverboardDistance ; distance in units from the boat to be considered overboard (default: 300)
float PlayerDistance ; current distance from the player to the boat (returned from GetDistance)

float SummonDistance ; distance in units to place the boat in front of the player when summoning (default: 350)
; summoning the boat goes haywire unless we give things time to "settle" this delays moving the boat a bit
float SummonTimer ; how much time left to wait before executing the next step of summoning (default: 0.5)
float SummonTimerDelay ; how long to wait in seconds after summoning to move boat to collider (default: 0.5)
float PlayerSin
float PlayerCos

; Dragging physics variables
float DragRopeLength ; how far the player can get before boat starts moving (default: 100)
float DragTautDistanceSquared ; current distance from player to tow point (squared)
float DragSlackDistance ; how much slack is in the rope
float PlayerMovementDistance
float PlayerMovementForce
float DragPointX ; point where the rope connects (center of boat)
float DragPointY
float DragTargetAngle
float DragForceX ; force applied to boat
float DragForceY
float DragBoatVelocityX ; boat's current drag velocity
float DragBoatVelocityY
float DragVelocitySquared
float DragFriction ; how quickly boat stops when not being pulled. 1.0 = no friction (default: 0.85)
float DragBaseTurnRate ; how fast boat rotates to match drag direction (default: 0.1)
float DragFrameTurnRate ; how much to rotate the boat this frame adjusted for the current frame rate
float DragMaxTurnPerFrame ; maximum angle to turn the boat per frame while dragging (default: 0.1)
float DragTurnDeadzone ; difference of degrees in player angle to boat angle to ignore before turning (default: 5)
float DragCurrentTurnRate ; current turn rate applied this frame while dragging adjusted with accel/decel smoothing
float DragTurnRateAcceleration ; how quickly to accelerate the turn rate while dragging (default: 0.15)
float DragTurnRateDeceleration ; how quickly to decelerate the turn rate while dragging (default: 0.92)
float DragAngleDiff ; difference between boat angle and drag angle
float DragPullStrength ; how strong the pull is (default: 0.005)
float DragMaxForce ; maximum force to apply to the boat (default: 0.5)
float DragMaxVelocity ; maximum velocity of the boat while dragging (default: 4.0)
float DragZInterpolationRate ; how quickly to interpolate the Z position of the boat to the player (default: 0.1)
float DragPlayerBoatZDiff ; difference between player Z and boat Z
float DragFrameBoatZAdjust ; adjustment to the boat Z position this frame based on player Z 
float DragLandPlayerZOffset ; offset from the player z to place the drag point, to raise the boat up (default: 30)
float DragMaxZPerFrame ; maximum Z distance to move the boat per frame while dragging (default: 0.1)
float DragMaxPlayerDistance ; maximum distance between player and boat before dragging is canceled (default: 1800)
float DragPitchAngle ; current smoothed pitch angle for dragging terrain
float DragTargetPitchAngle ; target pitch angle to smooth toward
float DragMaxPitchAngle ; maximum (absolute) pitch angle to apply while dragging (default: 45)
float DragPitchSmoothingFactor ; how quickly to smooth pitch changes (default: 0.15)
float DragPathStartX ; Start position of current path segment
float DragPathStartY
float DragPathStartZ
float DragPathDistance ; Distance traveled in current segment
float DragPathSlope ; Calculated slope of boat's path
float DragPathMinDistance ; Minimum distance before calculating slope (default: 50)
float DragPathSlopeFactor ; Factor to invert and minimize slope player path (default: -0.7)
float DragPathSlopeDeadzone ; Angle of player path that will not affect pitch (default: 2)
float DragTargetPitchMovingSmoothingFactor ; Additional smoothing factor on pitch applied while moving (default: 0.03)
float DragTargetPitchStoppedSmoothingFactor ; Additional smoothing factor on pitch applied while stopped (default: 0.02)
float DragUphillZAdjustmentFactor ; How much to adjust Z based on angle when going uphill (default: 6.0)
float DragDownhillZAdjustmentFactor ; How much to adjust Z based on angle when going downhill (default: 4.5)
; Boat drag angle calculation variables
float dX
float dY
float dXAbs
float dYAbs
float a
float r
float s

; Rocking animation variables
; IMPORTANT: Keep pitch and roll angles small (under 10-15 degrees) to avoid gimbal lock issues
; The boat's primary movement still relies on Z rotation, these are just visual effects
float RockingEnabled ; 0 = disabled, 1 = enabled (default: 1)
float RockPhase ; Current phase of the primary rocking motion (0-360)
float RockPhase2 ; Secondary rocking phase for more complex motion
float RockPhase3 ; Tertiary phase for roll motion
float RockAmplitudeZ ; How much the boat rocks up/down (in units) (default: 0.8)
float RockAmplitudePitch ; How much the boat pitches forward/back (in degrees) (default: 2.0)
float RockAmplitudeRoll ; How much the boat rolls side-to-side (in degrees) (default: 3.0)
float RockMaxAbsoluteZ ; Maximum BoatZ +/- Z offset value allowed from rocking (in units) (default: 3.0)
float RockFrequency ; How fast the boat rocks (degrees per second) (default: 30.0)
float RockFrequency2 ; Secondary frequency for complex motion (default: 45.0)
float RockFrequency3 ; Frequency for roll motion (default: 25.0)
float RockRandomPhase ; Random offset to make rocking look natural
float RockRandomTimer ; Timer for changing random values
float RockRandomInterval ; How often to change random values (in seconds) (default: 3.0)
float RockSpeedFactor ; How much boat speed affects rocking (default: 0.5)
float RockWeatherFactor ; Multiplier for bad weather (purely based on GetWindSpeed currently) (default: 0.5)
float WindSpeed ; Current wind speed (0-1) from GetWindSpeed
float RockDistanceThreshold ; Distance from player to enable rocking (in units) (default: 3000)
float TargetRockZOffset ; Target Z offset from rocking
float TargetRockPitchOffset ; Target pitch (X angle) offset from rocking
float TargetRockRollOffset ; Target roll (Y angle) offset from rocking
float RockZOffset ; Current smoothed boat Z offset from rocking
float RockPitchOffset ; Current smoothed pitch (X angle) offset from rocking
float RockRollOffset ; Current smoothed roll (Y angle) offset from rocking
float RockSmoothingFactor ; How quickly rocking starts from nothing and settles when stopped (default: 0.1)
float BoatPitchAngle ; Current pitch angle of boat
float BoatRollAngle ; Current roll angle of boat
; Sine approximation variables for rocking
float rockAng
float rockN
float rockT2
float rockSin
float rockSin2
float rockSin3
float rockCos3
; Attachment rotation calculation variables
float PitchRadians ; Pitch angle in radians for calculations
float RollRadians ; Roll angle in radians for calculations
float SinPitch ; Sine of pitch angle
float SinRoll ; Sine of roll angle
float CosPitch ; Cosine of pitch angle
float CosRoll ; Cosine of roll angle
float OrigX
float OrigY
float OrigZ
float TempX
float TempY
float TempZ
; Player weight influence variables
float PlayerWeightEnabled ; 0 = disabled, 1 = enabled (default: 1)
float PlayerLocalX ; Player's position relative to boat center (starboard/port)
float PlayerLocalY ; Player's position relative to boat center (bow/stern)
float PlayerLocalZ ; Player's position relative to boat center (up/down)
float PlayerRelativeX ; World relative position before rotation
float PlayerRelativeY ; World relative position before rotation
float PlayerDistanceFromCenter ; How far player is from boat center
float PlayerWeightInfluence ; 0-1 multiplier based on distance from center
float PlayerWeightMaxDistanceForward ; bow to stern max distance (default: 240)
float PlayerWeightMaxDistanceSide ; port to starboard max distance (default: 100)  
float PlayerWeightMaxDistanceVertical ; vertical max distance (default: 60)
float PlayerWeightPitchFactor ; How much player position affects pitch (default: 0.15)
float PlayerWeightRollFactor ; How much player position affects roll (default: 0.12)
float PlayerWeightPitchOffset ; Pitch offset caused by player weight
float PlayerWeightRollOffset ; Roll offset caused by player weight
float PlayerWeightSmoothingFactor ; How quickly weight effects change (default: 0.2)
float TargetPlayerWeightPitchOffset ; Target pitch offset for smoothing
float TargetPlayerWeightRollOffset ; Target roll offset for smoothing

ref BoatRef
float BoatX
float BoatY
float BoatZ
float BoatZWithRock ; BoatZ + RockZOffset
float BoatAngle

float PlayerX
float PlayerY
float PlayerZ
float PlayerAngle

float Diff
float Hemi
float BoatModelAngle ; boat's in-game model is rotated 90 degrees offset from 0, this stores true model angle
float TurnDeadzone ; difference of degrees in player angle to boat angle to ignore before turning (default: 10)

; Math variables for boat movement phyiscs
float pi
float halfPi
float radToDeg
float degToRad
float ang
float n
float t2
; (specific to boat yaw angle)
float sin
float cos
float tan

ref BoatMarker
float BoatMarkerZ
float BoatMarkerZOffset ; offset from the boat to place the map marker (default: 20)

ref Seat
float SeatX
float SeatY
float SeatZ
float SeatForwardOffset ; pos units from boat center along bow to stern to place the seat
float SeatSideOffset ; pos units from boat center along port to starboard to place the seat
float SeatZOffset ; pos units from BoatZ upwards to place the seat (default: 19)

ref Chest
float ChestX
float ChestY
float ChestZ
float ChestAngle
float ChestAngleOffset
float ChestForwardOffset ; pos units from boat center along bow to stern to place the chest
float ChestSideOffset ; pos units from boat center along port to starboard to place the chest
float ChestZOffset ; pos units from BoatZ upwards to place the chest (default: 15)

ref LampLit
ref LampUnlit
float LampX
float LampY
float LampZ
float LampForwardOffset ; pos units from boat center along bow to stern to place the lamp
float LampSideOffset ; pos units from boat center along port to starboard to place the lamp
float LampZOffset ; pos units from BoatZ upwards to place the lamp (default: 87)

ref Ladder
float LadderX
float LadderY
float LadderZ
float LadderForwardOffset ; pos units from boat center along bow to stern to place the ladder
float LadderSideOffset ; pos units from boat center along port to starboard to place the ladder
float LadderZOffset ; pos units from BoatZ upwards to place the ladder (default: -28)

ref Collider
float ColliderX
float ColliderActualX
float ColliderY
float ColliderActualY
float ColliderZ
float ColliderOffset ; pos units from boat center towards boat direction to place the collider
float ColliderOffsetReverse ; pos units from boat center towards the back of the boat to place the collider
float ColliderMoveFreq ; how often to move the collider in seconds (default: 0.05)
float ColliderMoveTimer ; current time left to wait before moving the collider again
float CollisionDetectDelay ; how long to wait in seconds at boat startup before checking for collision (default: 2)
float CollisionDetectTimer ; current time left to give for moving the boat away at startup before detecting collision
short CollisionDetectZThreshold ; Z position that the collider must be above to be considered colliding with something
; how close (in units) the collider must be to the expected position to trigger a collision (default: 1.0)
float ColliderPosThreshold

begin GameMode
    if (Initializing == 0)
        set Initializing to 1
        ; start in low-processing mode and switch to faster later on when boat is moving
        set fQuestDelayTime to LowUpdateRate
        ; Initialization is done in stage result scripts to save max script size space
        SetStage RYB 1 ; init constants
        SetStage RYB 2 ; init refs
        SetStage RYB 3 ; init collider
        SetStage RYB 4 ; init summoning
        SetStage RYB 5 ; init dragging
        SetStage RYB 6 ; init rocking
        SetStage RYB 7 ; init player weight
    endif

    if (ModVersion < 0.2)
        set ModVersion to 0.2
        set ColliderPosThreshold to 1.0
    endif

    if (Resetting == -1)
        SetStage RYB 51 ; Re-enable boat and attachment refs
        set Resetting to 1
    endif

    set PlayerDistance to BoatRef.GetDistance Player
    if (PlayerDistance < RockDistanceThreshold)
        if (RockingEnabled == 1)
            set fQuestDelayTime to HighUpdateRate ; high processing rate when near the boat for rocking animation
        else
            set fQuestDelayTime to MediumUpdateRate ; medium processing rate when nearby but rocking is disabled
        endif
        if (PlayerNearBoat == 0)
            ; Fix bug with boat disappearing after returning to the boat's cell by disabling all refs and re-enable in
            ; the next frame
            SetStage RYB 50 ; Disable boat and attachment refs
            set Resetting to -1 ; re-enable boat and attachment refs next frame
        endif
        set PlayerNearBoat to 1
    else
        set fQuestDelayTime to LowUpdateRate ; low processing rate when far away
        set PlayerNearBoat to 0
        ; SetStage RYB 50 ; Disable boat and attachment refs when away
    endif

    if (TriggerAutoRow == 1)
        set TriggerAutoRow to 0
        set BoatMoving to 1
        set fQuestDelayTime to HighUpdateRate 
        set AutoRowing to 1
        set Grounded to 0
        set DragTargetPitchAngle to 0
        Seat.SetDestroyed 1
        BoatMarker.Disable
        Ladder.Disable
        set LadderDeployed to 0

        set BaseBoatVelocity to BaseRowForce
        set CollisionDetectTimer to CollisionDetectDelay
    elseif (TriggerAutoRow == 2)
        set TriggerAutoRow to 0
        set BoatMoving to 1
        set Grounded to 0
        set DragTargetPitchAngle to 0
        set fQuestDelayTime to HighUpdateRate
        set AutoRowing to 2
        Seat.SetDestroyed 1
        BoatMarker.Disable
        Ladder.Disable
        set LadderDeployed to 0

        set BaseBoatVelocity to -BaseRowForce
        set CollisionDetectTimer to CollisionDetectDelay
    endif

    ; For some unknown reason, this player distance check only works in this script and not in the menu script
    if (TriggerRowCast > 0 && PlayerDistance > OverboardDistance)
        set TriggerRowCast to 0
        set RYBMenu.TriggerRowCast to 3 ; not near boat messagebox
    elseif (TriggerRowCast > 0 && Dragging >= 1)
        set TriggerRowCast to 0
        set RYBMenu.TriggerRowCast to 4 ; dragging boat messagebox
    elseif (TriggerRowCast > 0 && OnLand == 1)
        set TriggerRowCast to 0
        set RYBMenu.TriggerRowCast to 5 ; boat on land messagebox
    elseif (TriggerRowCast == 1)
        set TriggerRowCast to 0
        set AutoRowing to 0 ; rowing manually cancels auto rowing
        set Rowing to 1
        set RowTimer to RowSpellDuration
        if (BoatMoving == 0)
            set BoatMoving to 1
            set Grounded to 0
            set DragTargetPitchAngle to 0
            set fQuestDelayTime to HighUpdateRate
            Seat.SetDestroyed 1
            BoatMarker.Disable
            Ladder.Disable
            set LadderDeployed to 0
            set BaseBoatVelocity to BaseRowForce
            set CollisionDetectTimer to CollisionDetectDelay
        endif
    elseif (TriggerRowCast == 2)
        set TriggerRowCast to 0
        set AutoRowing to 0 ; rowing manually cancels auto rowing
        set DragTargetPitchAngle to 0
        set Rowing to 2
        set RowTimer to RowSpellDuration
        if (BoatMoving == 0)
            set BoatMoving to 1
            set Grounded to 0
            set fQuestDelayTime to HighUpdateRate
            Seat.SetDestroyed 1
            BoatMarker.Disable
            Ladder.Disable
            set LadderDeployed to 0
            set BaseBoatVelocity to -BaseRowForce
            set CollisionDetectTimer to CollisionDetectDelay
        endif
    endif

    if (TriggerGetOnBoat == 1)
        set TriggerGetOnBoat to 0
        SetStage RYB 11 ; Update boat position and angle
        set PlayerZ to BoatZ + 20

        ; TODO: this sometimes doesn't put the player on the boat
        Player.SetPos x BoatX
        Player.SetPos y BoatY
        Player.SetPos z PlayerZ
        Player.SetAngle z BoatAngle
        Message "You climbed onto the boat."
    elseif (TriggerGetOnBoat == 2)
        set TriggerGetOnBoat to 0
        Seat.Activate Player 1
    endif

    if (TriggerStartDragging == 1)
        set TriggerStartDragging to 0
        if (Dragging == 0)
            set Dragging to 1
            set DragTargetPitchAngle to 0 ; smooth reset to 0 pitch
            Player.AddItem RYBBoatToken 1
            set fQuestDelayTime to HighUpdateRate ; High update rate while dragging
            Seat.SetDestroyed 1
            BoatMarker.Disable
            set Grounded to 0
        
            ; stop the boat from moving while summoning
            set BaseBoatVelocity to 0
            set CurrentTurnRate to 0
            ; Initialize dragging state
            set DragBoatVelocityX to 0
            set DragBoatVelocityY to 0
            
            SetStage RYB 11 ; Update boat position and angle
            set DragTargetAngle to BoatAngle
            ; Initialize path tracking
            set DragPathStartX to Player.GetPos x
            set DragPathStartY to Player.GetPos y
            set DragPathStartZ to Player.GetPos z
            set DragPathSlope to 0

            if (OnLand == 1 && Player.IsSwimming == 0)
                ; When on land, raise the boat up a bit to indicate dragging has been activated
                set DragPlayerBoatZDiff to (PlayerZ + DragLandPlayerZOffset) - BoatZ
                set Dragging to 2 ; special state that allows z change until boat meets this z change
            endif
            
            Message "You are now dragging the boat."
        endif
    endif
    if (TriggerStopDragging == 1)
        set TriggerStopDragging to 0
        if (Dragging >= 1)
            set Dragging to 0
            if (RockingEnabled == 0)
                set fQuestDelayTime to MediumUpdateRate
            endif
            set DragBoatVelocityX to 0
            set DragBoatVelocityY to 0
            Player.RemoveItem RYBBoatToken 1
            Seat.SetDestroyed 0
            BoatMarker.Enable
            Message "You stop dragging the boat."
        endif
    endif

    if (TriggerSummonBoat >= 1)
        set fQuestDelayTime to HighUpdateRate
        ; stop the boat from moving while summoning
        set BoatMoving to 0
        set Grounded to 0
        Seat.SetDestroyed 0
        set BaseBoatVelocity to 0
        set CurrentTurnRate to 0
        set DragTargetPitchAngle to 0
        set PlayerX to Player.GetPos x
        set PlayerY to Player.GetPos y
        set PlayerZ to Player.GetPos z
        if (PlayerZ < 1)
            set PlayerZ to 1
        endif
        set PlayerAngle to Player.GetAngle z
        if (PlayerAngle < 0)
            set PlayerAngle to PlayerAngle + 360
        elseif (PlayerAngle >= 360)
            set PlayerAngle to PlayerAngle - 360
        endif
        set BoatAngle to PlayerAngle
        set BoatModelAngle to BoatAngle + 90
        if (BoatModelAngle < 0)
            set BoatModelAngle to BoatModelAngle + 360
        elseif (BoatModelAngle >= 360)
            set BoatModelAngle to BoatModelAngle - 360
        endif
        ; This positions the invisible collider SummonDistance units in front of the player.
        ; The game places actors in a way that avoids terrain and object collisions so this is a hack to prevent
        ; too much clipping on the boat when it is summoned.
        set ang to PlayerAngle
        SetStage RYB 18 ; Calculate sin/cos of the player angle

        if (TriggerSummonBoat == 1)
            set TriggerSummonBoat to 0
            Message "Summoning boat..."
            ; Use collider to find a good spot to place the boat in front of the player
            set ColliderX to PlayerX + (PlayerSin * SummonDistance)
            set ColliderY to PlayerY + (PlayerCos * SummonDistance)
            SetStage RYB 20 ; Enable and position collider

            ; need to wait for collider to move and "settle" before moving the boat to the spot the collider found
            set SummonTimer to SummonTimerDelay
            set Summoning to 1
            return
        elseif (TriggerSummonBoat == 2)
            set TriggerSummonBoat to 0
            Message "Placing boat..."
            set BoatX to PlayerX + (PlayerSin * SummonDistance)
            set BoatY to PlayerY + (PlayerCos * SummonDistance)
            set BoatZ to PlayerZ
            ; Disable all the refs first since they need to be disabled and enabled one frame later to appear correctly
            SetStage RYB 50 ; Disable boat and attachment refs
            BoatRef.MoveTo Player
            BoatRef.SetPos x, BoatX
            BoatRef.SetPos y, BoatY
            BoatRef.SetPos z, BoatZ
            BoatRef.SetAngle z, BoatModelAngle
            set Summoning to 2
            return
        endif
    endif

    if (SummonTimer > 0)
        set SummonTimer to SummonTimer - SecondsPassed
    elseif (SummonTimer <= 0 && Summoning == 1) ; time to move the boat to the collider
        set BoatX to Collider.GetPos x
        set BoatY to Collider.GetPos y
        set BoatZ to Collider.GetPos z
        set BoatZ to BoatZ - RockZOffset ; remove rocking offset from last frame to get "true" Z
        if (BoatZ < (WaterLevelZ + 1))
            set BoatZ to WaterLevelZ + 1
        endif
        SetStage RYB 50 ; Disable boat and attachment refs
        BoatRef.MoveTo Player
        BoatRef.SetPos x, BoatX
        BoatRef.SetPos y, BoatY
        BoatRef.SetPos z, BoatZ
        BoatRef.SetAngle z, BoatModelAngle

        Collider.Disable
        set Summoning to 2
        return
        ; set SummonTimer to SummonTimerDelay ; this delay maybe not necessary
    elseif (Summoning == 2)
        set Summoning to 0
        SetStage RYB 51 ; Re-enable boat and attachment refs
        if (RockingEnabled == 0)
            set fQuestDelayTime to MediumUpdateRate
        endif
        set Resetting to 1
    endif

    if (LampOn == 1 && LampLit.GetDisabled == 1 && Resetting != -1)
        set Resetting to 1
        LampLit.Enable
        LampUnlit.PlaySound3D SPLFireballFail
    elseif (LampOn == 0 && LampLit.GetDisabled == 0 && Resetting != -1)
        set Resetting to 1
        LampLit.Disable
        LampUnlit.PlaySound3D ITMTorchHeldExt
    endif

    set SecondsPassed to GetSecondsPassed
    ; Clamp extreme values
    if (SecondsPassed < 0.001)
        set SecondsPassed to 0.001
    elseif (SecondsPassed > 0.1)
        set SecondsPassed to 0.1
    endif

    ; Exponentially smooth the delta time to adjust for frame rate changes
    set SmoothedDeltaTime to ((1.0 - DeltaSmoothingFactor) * SmoothedDeltaTime) + (DeltaSmoothingFactor * SecondsPassed)

    ; Speed values assume a frame rate of 60fps so readjust speed values to current frame rate
    set FrameRowForce to BaseRowForce * (SmoothedDeltaTime / TargetDeltaTime)

    if (Rowing == 0 && AutoRowing == 0 && BoatMoving == 2)
        ; Boat is moving, but not rowing. Decay the velocity using exponential decay.
        ; velocity = velocity * (1 - decay * time)
        if (BaseBoatVelocity != 0)
            ; Calculate decay factor based on smoothed delta time
            ; Convert to time-based decay
            ; retention^(frames) = retention^(time/frameTime)
            ; We need to calculate r^(SmoothedDeltaTime/TargetDeltaTime)
            
            ; Approximation since we can't do pow():
            ; For small time steps, r^t ≈ 1 + t*ln(r)
            ; ln(0.98) ≈ -0.0202
            set FrameVelocityDecay to 1 + (SmoothedDeltaTime / TargetDeltaTime) * (VelocityDecayLnRetentionFactor)
            set BaseBoatVelocity to BaseBoatVelocity * FrameVelocityDecay
            
            ; Stop when very slow
            if (BaseBoatVelocity > -0.2 && BaseBoatVelocity < 0.2)
                set BaseBoatVelocity to 0
                set BoatMoving to 0
                if (RockingEnabled == 0)
                    set fQuestDelayTime to MediumUpdateRate
                endif
                Seat.SetDestroyed 0
                BoatMarker.Enable
                Collider.Disable
            endif
        endif
    endif

    if ((Rowing == 1 || AutoRowing == 1) && BoatMoving == 2 && BaseBoatVelocity < BoatMaxVelocity)
        ; Don't allow the boat to accelerate forever past max speed
        set BaseBoatVelocity to BaseBoatVelocity + FrameRowForce
        if (BaseBoatVelocity >= BoatMaxVelocity)
            set BaseBoatVelocity to BoatMaxVelocity
        endif
    endif

    if ((Rowing == 2 || AutoRowing == 2) && BoatMoving == 2 && BaseBoatVelocity > -BoatMaxVelocity)
        ; Don't allow the boat to accelerate backwards forever past max negative speed
        set BaseBoatVelocity to BaseBoatVelocity - FrameRowForce
        if (BaseBoatVelocity <= -BoatMaxVelocity)
            set BaseBoatVelocity to -BoatMaxVelocity
        endif
    endif

    if (RowTimer > 0)
        set RowTimer to RowTimer - SecondsPassed
    elseif (RowTimer <= 0 && Rowing > 0)
        set Rowing to 0
    endif

    if (BoatMoving == 2 && PlayerDistance > OverboardDistance)
        set Rowing to 0
        set CurrentTurnRate to 0 ; immediately stop turning
        set AutoRowing to 0
        set LadderDeployed to 1
        Ladder.Enable
        set Resetting to 1
        Message "You've gone overboard!"
    endif

    if (BoatMoving == 2 && CollisionDetectTimer > 0)
        set CollisionDetectTimer to CollisionDetectTimer - SecondsPassed
    elseif (BoatMoving == 2 && CollisionDetectTimer <= 0 && Collider.GetInSameCell Player && Collider.GetPos z > CollisionDetectZThreshold)
        set ColliderActualX to Collider.GetPos x
        set ColliderActualY to Collider.GetPos y
        if (ColliderActualX > ColliderX - ColliderPosThreshold && ColliderActualX < ColliderX + ColliderPosThreshold && ColliderActualY > ColliderY - ColliderPosThreshold && ColliderActualY < ColliderY + ColliderPosThreshold)
            if (RockingEnabled == 0)
                set fQuestDelayTime to MediumUpdateRate
            endif
            SetStage RYB 21 ; Collision procedure
        endif
    elseif (BoatMoving == 2 && CollisionDetectTimer <= 0 && Collider.GetDead == 1)
        ; Moving the collider every frame seems to cause the collider to spontaneously die when near land. However, this
        ; also seems to have many false positives where it dies in open water. Instead of every frame, the script uses
        ; ColliderMoveTimer to move it every N seconds instead of every frame. The Collider doesn't seem to
        ; spontaneously die with this method, but I kept this here just in-case it ever does happen.
        if (RockingEnabled == 0)
            set fQuestDelayTime to MediumUpdateRate
        endif
        Collider.Resurrect 0
        SetStage RYB 21 ; Collision procedure
    endif

    if (BoatMoving >= 1 && (Player.GetSitting != 0 && Player.GetSitting != 3))
        ; wait for player to sit/standup before continuing to move
        Message "Pausing the boat until you get up."
        return
    endif

    ; Boat dragging. See visualization here: https://claude.ai/public/artifacts/23380c6b-c9a4-430d-bd86-781ae588739f
    if (Dragging >= 1)
        set PlayerX to Player.GetPos x
        set PlayerY to Player.GetPos y
        set PlayerZ to Player.GetPos z
        SetStage RYB 11 ; Update boat position and angle

        if (PlayerDistance > DragMaxPlayerDistance)
            set Dragging to 0
            Player.RemoveItem RYBBoatToken 1
            if (RockingEnabled == 0)
                set fQuestDelayTime to MediumUpdateRate
            endif
            set DragBoatVelocityX to 0
            set DragBoatVelocityY to 0
            Seat.SetDestroyed 0
            BoatMarker.Enable
            Message "You got too far from the boat and stopped dragging it."
        endif
        
        ; Drag point is at center of boat
        set DragPointX to BoatX
        set DragPointY to BoatY
        ; Vector from rope attach point (center of boat) to player
        set dX to PlayerX - DragPointX
        set dY to PlayerY - DragPointY

        ; Save absolute values of dX and dY
        if (dX < 0)
            set dXAbs to -dX
        else
            set dXAbs to dX
        endif
        if (dY < 0)
            set dYAbs to -dY
        else
            set dYAbs to dY
        endif

        if (dXAbs < 0.1 && dYAbs < 0.1)
            ; Player is very close to the drag point, so no need to calculate angle
            set DragTargetAngle to BoatAngle
        else
            SetStage RYB 10 ; Calculate DragTargetAngle with atan2(dY, dX)
        endif

        ; Calculate squared distance from player to drag point
        set DragTautDistanceSquared to ((PlayerX - DragPointX) * (PlayerX - DragPointX)) + ((PlayerY - DragPointY) * (PlayerY - DragPointY))
        
        ; Only apply force if rope is taut (player far enough away)
        if (DragTautDistanceSquared > (DragRopeLength * DragRopeLength))
            ; Get actual distance using Newton's method for square root (2 iterations is usually enough)
            ; See: https://cs.uesp.net/wiki/Square_Root
            set PlayerMovementDistance to DragRopeLength + 50  ; Initial reasonable guess
            ; Iteration 1: x = (x + n/x) / 2
            set PlayerMovementDistance to (PlayerMovementDistance + (DragTautDistanceSquared / PlayerMovementDistance)) / 2
            ; Iteration 2: x = (x + n/x) / 2
            set PlayerMovementDistance to (PlayerMovementDistance + (DragTautDistanceSquared / PlayerMovementDistance)) / 2
            
            ; Calculate normalized direction from drag point to player
            if (PlayerMovementDistance > 0)
                set DragForceX to (PlayerX - DragPointX) / PlayerMovementDistance
                set DragForceY to (PlayerY - DragPointY) / PlayerMovementDistance
                
                ; Apply pulling force based on how far beyond rope length we are
                set DragSlackDistance to PlayerMovementDistance - DragRopeLength

                ; Instead of linear, use a dampened response
                if (DragSlackDistance > 100)
                    ; If very far, use logarithmic-like response to prevent extreme forces
                    set DragSlackDistance to 100 + (DragSlackDistance - 100) * 0.1
                endif

                set PlayerMovementForce to DragSlackDistance * DragPullStrength

                if (PlayerMovementForce > DragMaxForce)
                    set PlayerMovementForce to DragMaxForce
                endif
                
                ; Simple spring force: the further stretched, the stronger the pull
                set DragForceX to DragForceX * PlayerMovementForce
                set DragForceY to DragForceY * PlayerMovementForce
                
                ; Apply force to velocity
                set DragBoatVelocityX to DragBoatVelocityX + (DragForceX * SmoothedDeltaTime / TargetDeltaTime)
                set DragBoatVelocityY to DragBoatVelocityY + (DragForceY * SmoothedDeltaTime / TargetDeltaTime)

                ; Limit max velocity
                set DragVelocitySquared to (DragBoatVelocityX * DragBoatVelocityX) + (DragBoatVelocityY * DragBoatVelocityY)
                if (DragVelocitySquared > (DragMaxVelocity * DragMaxVelocity))
                    ; Get actual velocity
                    set PlayerMovementDistance to DragMaxVelocity  ; Start with max
                    set PlayerMovementDistance to (PlayerMovementDistance + (DragVelocitySquared / PlayerMovementDistance)) / 2
                    
                    ; Scale down to max velocity
                    set DragBoatVelocityX to DragBoatVelocityX * (DragMaxVelocity / PlayerMovementDistance)
                    set DragBoatVelocityY to DragBoatVelocityY * (DragMaxVelocity / PlayerMovementDistance)
                endif
                
                ; Calculate angle difference to movement direction
                set DragAngleDiff to DragTargetAngle - BoatAngle
                
                if (DragAngleDiff > 180)
                    set DragAngleDiff to DragAngleDiff - 360
                elseif (DragAngleDiff < -180)
                    set DragAngleDiff to DragAngleDiff + 360
                endif
                if (DragAngleDiff < DragTurnDeadzone && DragAngleDiff > -DragTurnDeadzone)
                    ; Within deadzone - decay the turn rate
                    set DragCurrentTurnRate to DragCurrentTurnRate * DragTurnRateDeceleration
                    ; Stop tiny movements
                    if (DragCurrentTurnRate > -0.01 && DragCurrentTurnRate < 0.01)
                        set DragCurrentTurnRate to 0
                    endif
                else
                    ; Outside deadzone - calculate target turn rate and ramp up toward it
                    set DragFrameTurnRate to DragAngleDiff * DragBaseTurnRate * (SmoothedDeltaTime / TargetDeltaTime)
                    if (DragFrameTurnRate > DragMaxTurnPerFrame) 
                        set DragFrameTurnRate to DragMaxTurnPerFrame
                    elseif (DragFrameTurnRate < -DragMaxTurnPerFrame)
                        set DragFrameTurnRate to -DragMaxTurnPerFrame
                    endif
                    
                    ; Smoothly ramp up to target turn rate
                    set DragCurrentTurnRate to DragCurrentTurnRate + ((DragFrameTurnRate - DragCurrentTurnRate) * DragTurnRateAcceleration * SmoothedDeltaTime / TargetDeltaTime)
                endif

                set BoatAngle to BoatAngle + DragCurrentTurnRate
            endif
        endif
        
        ; Apply friction to velocity (always, even when not pulling)
        set DragBoatVelocityX to DragBoatVelocityX * DragFriction
        set DragBoatVelocityY to DragBoatVelocityY * DragFriction

        ; Update boat position based on velocity
        set BoatX to BoatX + (DragBoatVelocityX * SmoothedDeltaTime / TargetDeltaTime)
        set BoatY to BoatY + (DragBoatVelocityY * SmoothedDeltaTime / TargetDeltaTime)
        
        ; Only allow changing Z pos and pitch angle if rope is taut so the player can't ride the boat up into the air
        ; (not a plane mod yet ;D)
        if (DragTautDistanceSquared > (DragRopeLength * DragRopeLength))
            ; Smoothly interpolate boat Z towards target
            if (Player.IsSwimming == 1)
                set DragPlayerBoatZDiff to PlayerZ - BoatZ
            else
                ; Raise the boat up a bit when on land so it doesn't clip into the ground as much
                set DragPlayerBoatZDiff to (PlayerZ + DragLandPlayerZOffset) - BoatZ
            endif

            ; Calculate distance boat has traveled from start of path segment
            set dX to PlayerX - DragPathStartX
            set dY to PlayerY - DragPathStartY
            set DragPathDistance to (dX * dX) + (dY * dY)
            
            ; If boat has moved enough, calculate the slope it traveled
            if (DragPathDistance > (DragPathMinDistance * DragPathMinDistance))
                ; Get actual distance using Newton's method
                set DragPathDistance to DragPathMinDistance ; Initial guess
                set DragPathDistance to (DragPathDistance + ((dX * dX + dY * dY) / DragPathDistance)) / 2
                set DragPathDistance to (DragPathDistance + ((dX * dX + dY * dY) / DragPathDistance)) / 2
                
                ; Calculate slope from player's actual path
                set DragPathSlope to ((PlayerZ - DragPathStartZ) / DragPathDistance) * radToDeg * -DragPathSlopeFactor
                
                ; Apply deadzone to ignore tiny slopes
                if (DragPathSlope > -DragPathSlopeDeadzone && DragPathSlope < DragPathSlopeDeadzone)
                    set DragPathSlope to 0
                endif
                
                ; Clamp calculated slope to reasonable values
                if (DragPathSlope > DragMaxPitchAngle)
                    set DragPathSlope to DragMaxPitchAngle
                elseif (DragPathSlope < -DragMaxPitchAngle)
                    set DragPathSlope to -DragMaxPitchAngle
                endif
                
                ; Start new path segment from current position
                set DragPathStartX to PlayerX
                set DragPathStartY to PlayerY
                set DragPathStartZ to PlayerZ
            endif
            
            if (Player.IsSwimming == 1)
                set DragTargetPitchAngle to 0 ; Reset pitch when swimming
            else
                ; Only adjust pitch when boat is moving and player is not swimming
                if (DragBoatVelocityX != 0 || DragBoatVelocityY != 0)
                    ; Smoothly adjust target pitch toward the path slope
                    set DragTargetPitchAngle to DragTargetPitchAngle + ((DragPathSlope - DragTargetPitchAngle) * DragTargetPitchMovingSmoothingFactor)
                else
                    ; When stopped, very slowly tend toward path slope
                    set DragTargetPitchAngle to DragTargetPitchAngle + ((DragPathSlope - DragTargetPitchAngle) * DragTargetPitchStoppedSmoothingFactor)
                endif

                ; Z adjustment based on pitch angle to prevent clipping going up and down hills
                if (DragPlayerBoatZDiff >= 0)
                    ; raise boat when player going downhill
                    set DragPlayerBoatZDiff to DragPlayerBoatZDiff + (DragTargetPitchAngle * DragDownhillZAdjustmentFactor)
                else
                    ; lower boat when player going uphill (DragTargetPitchAngle is negative)
                    set DragPlayerBoatZDiff to DragPlayerBoatZDiff + (DragTargetPitchAngle * DragUphillZAdjustmentFactor)
                endif
            endif
        endif

        if (Dragging == 2 || DragTautDistanceSquared > (DragRopeLength * DragRopeLength))
            set DragFrameBoatZAdjust to (DragPlayerBoatZDiff * DragZInterpolationRate * SmoothedDeltaTime / TargetDeltaTime)
            if (Dragging == 2)
                ; This is a one-time adjustment, so remove this frame's adjustment from the total target adjustment
                set DragPlayerBoatZDiff to DragPlayerBoatZDiff - DragFrameBoatZAdjust
                if ((DragFrameBoatZAdjust > 0 && DragPlayerBoatZDiff <= 0) || (DragFrameBoatZAdjust < 0 && DragPlayerBoatZDiff > 0) || DragPlayerBoatZDiff == 0)
                    set Dragging to 1 ; target reached, proceed with normal dragging
                endif
            endif

            ; Prevent "boat becomes a missile" issue
            if (DragFrameBoatZAdjust > DragMaxZPerFrame)
                set DragFrameBoatZAdjust to DragMaxZPerFrame
            elseif (DragFrameBoatZAdjust < -DragMaxZPerFrame)
                set DragFrameBoatZAdjust to -DragMaxZPerFrame
            endif
            set BoatZ to BoatZ + DragFrameBoatZAdjust
        endif
        
        ; Prevent boat from going below water level
        if (BoatZ < (WaterLevelZ + 1))
            set BoatZ to WaterLevelZ + 1
        endif
        
        ; Stop tiny movements
        if (DragBoatVelocityX > -0.1 && DragBoatVelocityX < 0.1)
            set DragBoatVelocityX to 0
        endif
        if (DragBoatVelocityY > -0.1 && DragBoatVelocityY < 0.1)
            set DragBoatVelocityY to 0
        endif
    endif

    ; Smooth the actual pitch angle toward target (outside the dragging check)
    if (DragPitchAngle != DragTargetPitchAngle)
        set DragPitchAngle to DragPitchAngle + ((DragTargetPitchAngle - DragPitchAngle) * DragPitchSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        
        ; Stop tiny movements
        if (DragPitchAngle > -0.05 && DragPitchAngle < 0.05)
            set DragPitchAngle to 0
        endif
    endif

    ; TODO: test if it's necessary to set these every update while moving.
    ; In theory, they only need to be set once at initialization since the boat is immovable beyond this script.
    ; (I want to see if resetting these fixes get on boat issues)
    ; Doesn't 100% fix it, but maybe it helps a bit? Not sure.
    if (Summoning == 0 && Dragging == 0)
        ; During summoning and dragging these are preset so don't overwrite them
        SetStage RYB 11 ; Update boat position and angle
    endif

    ; Calculate player weight influence on boat pitch and roll
    if (PlayerWeightEnabled == 1 && Summoning == 0 && Dragging == 0 && PlayerDistance < PlayerWeightMaxDistanceForward)
        ; Get player position
        set PlayerX to Player.GetPos x
        set PlayerY to Player.GetPos y
        set PlayerZ to Player.GetPos z
        
        ; Calculate player position relative to boat center
        set PlayerRelativeX to PlayerX - BoatX
        set PlayerRelativeY to PlayerY - BoatY

        ; Calculate boat's forward and right vectors using BoatAngle directly
        ; Forward vector (bow direction): sin(BoatAngle), cos(BoatAngle)
        ; Right vector (starboard direction): cos(BoatAngle), -sin(BoatAngle)
        ; PlayerLocalY: positive = toward bow, negative = toward stern
        set PlayerLocalY to PlayerRelativeX * sin + PlayerRelativeY * cos
        ; PlayerLocalX: positive = toward starboard, negative = toward port  
        set PlayerLocalX to PlayerRelativeX * cos - PlayerRelativeY * sin
        set PlayerLocalZ to PlayerZ - BoatZWithRock
          
        ; Calculate distance from boat center for falloff effect
        set PlayerDistanceFromCenter to PlayerRelativeX * PlayerRelativeX + PlayerRelativeY * PlayerRelativeY
        ; Newton's method square root approximation (2 iterations)
        set PlayerDistanceFromCenter to PlayerWeightMaxDistanceForward ; Initial guess
        set PlayerDistanceFromCenter to (PlayerDistanceFromCenter + ((PlayerRelativeX * PlayerRelativeX + PlayerRelativeY * PlayerRelativeY) / PlayerDistanceFromCenter)) / 2
        set PlayerDistanceFromCenter to (PlayerDistanceFromCenter + ((PlayerRelativeX * PlayerRelativeX + PlayerRelativeY * PlayerRelativeY) / PlayerDistanceFromCenter)) / 2
        
        ; Calculate influence factor (1.0 at center, 0.0 at max distance)
        ; Limit effect area to a box approximately the area above the boat up 60 units (PlayerWeightMaxDistanceVertical)
        if (PlayerDistanceFromCenter <= PlayerWeightMaxDistanceForward && PlayerLocalZ < PlayerWeightMaxDistanceVertical && PlayerLocalX < PlayerWeightMaxDistanceSide && PlayerLocalX > -PlayerWeightMaxDistanceSide)
            set PlayerWeightInfluence to 1.0 - (PlayerDistanceFromCenter / PlayerWeightMaxDistanceForward)
        else
            set PlayerWeightInfluence to 0
        endif
        
        ; Calculate target pitch offset based on player's fore/aft position
        ; Positive PlayerLocalY = toward bow (front) = boat should pitch forward (bow dips down)
        ; Negative PlayerLocalY = toward stern (back) = boat should pitch backward (stern dips down)
        set TargetPlayerWeightPitchOffset to PlayerLocalY * PlayerWeightPitchFactor * PlayerWeightInfluence
        
        ; Calculate target roll offset based on player's port/starboard position  
        ; Positive PlayerLocalX = toward starboard (right) = boat should roll starboard (startboard dips down)
        ; Negative PlayerLocalX = toward port (left) = boat should roll port (port dips down)
        set TargetPlayerWeightRollOffset to -PlayerLocalX * PlayerWeightRollFactor * PlayerWeightInfluence
        
        ; Smooth the transition to prevent jarring movements
        set PlayerWeightPitchOffset to PlayerWeightPitchOffset + ((TargetPlayerWeightPitchOffset - PlayerWeightPitchOffset) * PlayerWeightSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        set PlayerWeightRollOffset to PlayerWeightRollOffset + ((TargetPlayerWeightRollOffset - PlayerWeightRollOffset) * PlayerWeightSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
    else
        ; Player not on boat or system disabled - gradually return to neutral
        set PlayerWeightPitchOffset to PlayerWeightPitchOffset * (1 - PlayerWeightSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        set PlayerWeightRollOffset to PlayerWeightRollOffset * (1 - PlayerWeightSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        
        ; Stop tiny movements
        if (PlayerWeightPitchOffset > -0.01 && PlayerWeightPitchOffset < 0.01)
            set PlayerWeightPitchOffset to 0
        endif
        if (PlayerWeightRollOffset > -0.01 && PlayerWeightRollOffset < 0.01)
            set PlayerWeightRollOffset to 0
        endif
    endif

    if (BoatMoving >= 1 || Dragging >= 1 || Resetting >= 1)
        ; Speed values assume a frame rate of 60fps so readjust speed values to current frame rate
        set FrameBoatVelocity to BaseBoatVelocity * (SmoothedDeltaTime / TargetDeltaTime)

        ; Calculate new boat angle. Script originally by Jason1
        set PlayerAngle to Player.GetAngle z
        if (PlayerAngle < 0)
            set PlayerAngle to PlayerAngle + 360
        elseif (PlayerAngle >= 360)
            set PlayerAngle to PlayerAngle - 360
        endif

        if (BoatMoving >= 1 && Dragging == 0 && Summoning == 0 && LockHeading == 0)
            set Diff to PlayerAngle - BoatAngle

            ; Calculate velocity-based turn modifier to make boats turn slower when moving slowly for realism
            if (BaseBoatVelocity < 0)
                set AbsoluteBoatVelocity to -BaseBoatVelocity
            else
                set AbsoluteBoatVelocity to BaseBoatVelocity
            endif

            ; Turn rate scales with velocity (0.3 to 1.0 multiplier)
            set TurnRateVelocityFactor to 0.3 + (0.7 * (AbsoluteBoatVelocity / BoatMaxVelocity))
            if (TurnRateVelocityFactor > 1.0)
                set TurnRateVelocityFactor to 1.0
            endif

            set FrameTurnRate to BaseTurnRate * TurnRateVelocityFactor * (SmoothedDeltaTime / TargetDeltaTime)

            if ((Diff > 1 ||  Diff < -1) && (Diff > TurnDeadzone || Diff < -TurnDeadzone))
                ; Player is currently turning, ramp up turn rate
                set CurrentTurnRate to CurrentTurnRate + ((FrameTurnRate - CurrentTurnRate) * TurnRateAcceleration * SmoothedDeltaTime / TargetDeltaTime)
            else
                ; Player not turning, decay the turn rate
                set CurrentTurnRate to CurrentTurnRate * TurnRateDeceleration
                ; Stop tiny movements
                if (CurrentTurnRate > -0.05 && CurrentTurnRate < 0.05)
                    set CurrentTurnRate to 0
                endif
            endif

            if (CurrentTurnRate != 0 && (Diff > 1 || Diff < -1))
                if (PlayerAngle > 180)
                    set Hemi to PlayerAngle - 180
                else
                    set Hemi to PlayerAngle + 180
                endif
                if (Hemi < 0)
                    set Hemi to Hemi + 360
                elseif (Hemi >= 360)
                    set Hemi to Hemi - 360
                endif
                if (PlayerAngle > Hemi)
                    if (BoatAngle > Hemi && BoatAngle < PlayerAngle)
                        set BoatAngle to BoatAngle + CurrentTurnRate
                    else
                        set BoatAngle to BoatAngle - CurrentTurnRate
                    endif
                else
                    if (BoatAngle < Hemi && BoatAngle > PlayerAngle)
                        set BoatAngle to BoatAngle - CurrentTurnRate
                    else
                        set BoatAngle to BoatAngle + CurrentTurnRate
                    endif				
                endif
            endif

            if (BoatAngle < 0)
                set BoatAngle to BoatAngle + 360
            elseif (BoatAngle >= 360)
                set BoatAngle to BoatAngle - 360
            endif
        else
            ; Player not turning - decay the turn rate
            set CurrentTurnRate to CurrentTurnRate * TurnRateDeceleration
            ; Stop tiny movements
            if (CurrentTurnRate > -0.05 && CurrentTurnRate < 0.05)
                set CurrentTurnRate to 0
            endif
        endif

		; Adjust for model alignment (boat model is rotated 90 degrees)
		set BoatModelAngle to BoatAngle + 90
		if (BoatModelAngle < 0)
			set BoatModelAngle to BoatModelAngle + 360
		elseif (BoatModelAngle >= 360)
			set BoatModelAngle to BoatModelAngle - 360
		endif

        set BoatX to BoatX + (sin * FrameBoatVelocity)
        set BoatY to BoatY + (cos * FrameBoatVelocity)
        if (BoatMoving >= 1 && Dragging == 0 && OnLand == 0 && BoatZ != (WaterLevelZ + 1))
            set BoatZ to WaterLevelZ + 1 ; if boat started moving above water, reset it to water level
        endif
        set BoatZWithRock to BoatZ + RockZOffset
        if (Resetting != 2)
		    BoatRef.MoveTo Player
        endif
		BoatRef.SetPos x, BoatX
		BoatRef.SetPos y, BoatY
        BoatRef.SetPos z, BoatZWithRock
        BoatRef.SetAngle z, BoatModelAngle
        BoatRef.SetAngle x, BoatPitchAngle
        BoatRef.SetAngle y, BoatRollAngle
    endif

    if (BoatZ > LandZThreshold)
        set OnLand to 1
    else
        set OnLand to 0
    endif

    ; Boat rocking animation
    if (RockingEnabled == 1 && Dragging == 0 && Summoning == 0 && Grounded == 0 && OnLand == 0 && PlayerNearBoat == 1)
        ; Update random variation
        if (RockRandomTimer <= 0)
            set RockRandomTimer to RockRandomInterval
            ; Add some random variation to make it look natural
            set RockRandomPhase to (GetRandomPercent - 50) * 0.02
        else
            set RockRandomTimer to RockRandomTimer - SecondsPassed
        endif
        
        ; Update rocking phases
        set RockPhase to RockPhase + (RockFrequency * SecondsPassed)
        if (RockPhase >= 360)
            set RockPhase to RockPhase - 360
        endif
        
        set RockPhase2 to RockPhase2 + (RockFrequency2 * SecondsPassed)
        if (RockPhase2 >= 360)
            set RockPhase2 to RockPhase2 - 360
        endif
        
        set RockPhase3 to RockPhase3 + (RockFrequency3 * SecondsPassed)
        if (RockPhase3 >= 360)
            set RockPhase3 to RockPhase3 - 360
        endif
        
        SetStage RYB 15 ; Calculate sine for primary rocking (Z movement and pitch)
        SetStage RYB 16 ; Calculate sine for secondary rocking
        SetStage RYB 17 ; Calculate sine and cosine for roll motion
        
        ; Calculate rocking offsets
        ; Z movement: combine multiple sine waves
        set TargetRockZOffset to RockAmplitudeZ * (rockSin * 0.7 + rockSin2 * 0.3 + RockRandomPhase)
        
        ; Pitch (X rotation): boat tips forward/backward
        set TargetRockPitchOffset to RockAmplitudePitch * (rockSin * 0.8 + rockSin2 * 0.2) + PlayerWeightPitchOffset
        
        ; Roll (Y rotation): boat tips side to side, offset by 90 degrees using cosine
        set TargetRockRollOffset to RockAmplitudeRoll * (rockCos3 * 0.7 + rockSin2 * 0.3) + PlayerWeightRollOffset
        
        ; Adjust for boat speed (more rocking when moving)
        if (BoatMoving >= 1)
            if (BaseBoatVelocity < 0)
                set AbsoluteBoatVelocity to -BaseBoatVelocity
            else
                set AbsoluteBoatVelocity to BaseBoatVelocity
            endif
            ; Increase rocking amplitude based on speed
            set TargetRockZOffset to TargetRockZOffset * (1 + (AbsoluteBoatVelocity / BoatMaxVelocity) * RockSpeedFactor)
            set TargetRockPitchOffset to TargetRockPitchOffset * (1 + (AbsoluteBoatVelocity / BoatMaxVelocity) * RockSpeedFactor * 1.5)
            set TargetRockRollOffset to TargetRockRollOffset * (1 + (AbsoluteBoatVelocity / BoatMaxVelocity) * RockSpeedFactor * 0.7)
        endif

        ; Apply weather factor (based on wind speed)
        set WindSpeed to GetWindSpeed
        set TargetRockZOffset to TargetRockZOffset * (1 + (WindSpeed * RockWeatherFactor))
        ; Limit extreme Z offsets that would mess with boat-in-water detection
        if (BoatZ + TargetRockZOffset < -RockMaxAbsoluteZ)
            set TargetRockZOffset to -RockMaxAbsoluteZ - BoatZ
        elseif (BoatZ + TargetRockZOffset > RockMaxAbsoluteZ)
            set TargetRockZOffset to RockMaxAbsoluteZ - BoatZ
        endif
        set TargetRockPitchOffset to TargetRockPitchOffset * (1 + (WindSpeed * RockWeatherFactor))
        set TargetRockRollOffset to TargetRockRollOffset * (1 + (WindSpeed * RockWeatherFactor))

        ; Smooth out the rocking effects so it doesn't snap into rocking position on boat launch
        set RockZOffset to RockZOffset + ((TargetRockZOffset - RockZOffset) * RockSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        set RockPitchOffset to RockPitchOffset + ((TargetRockPitchOffset - RockPitchOffset) * RockSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        set RockRollOffset to RockRollOffset + ((TargetRockRollOffset - RockRollOffset) * RockSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
    else
        ; Dampen rocking when conditions aren't met
        set RockZOffset to RockZOffset * (1 - RockSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        set RockPitchOffset to RockPitchOffset * (1 - RockSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        set RockRollOffset to RockRollOffset * (1 - RockSmoothingFactor * SmoothedDeltaTime / TargetDeltaTime)
        
        ; Stop tiny movements
        if (RockZOffset > -0.01 && RockZOffset < 0.01)
            set RockZOffset to 0
        endif
        if (RockPitchOffset > -0.01 && RockPitchOffset < 0.01)
            set RockPitchOffset to 0
        endif
        if (RockRollOffset > -0.01 && RockRollOffset < 0.01)
            set RockRollOffset to 0
        endif
    endif

    if (BoatMoving >= 1 || Dragging >= 1 || Resetting >= 1 || (PlayerNearBoat == 1 && (RockZOffset != 0 || RockPitchOffset != 0 || RockRollOffset != 0)))
        set ang to BoatAngle
        SetStage RYB 12 ; Calculate sin, cos, & tan for boat angle
    endif

    if (BoatMoving >= 1 || Dragging >= 1 || Resetting >= 1 || (PlayerNearBoat == 1 && (RockZOffset != 0 || RockPitchOffset != 0 || RockRollOffset != 0)))
        ; Transform world pitch/roll to boat's local pitch/roll
        set BoatPitchAngle to (RockPitchOffset + DragPitchAngle) * cos + RockRollOffset * sin
        set BoatRollAngle to -(RockPitchOffset + DragPitchAngle) * sin + RockRollOffset * cos
        
        ; Calculate sine/cosine for the transformed angles
        if (BoatPitchAngle != 0)
            SetStage RYB 13 ; Calculate sin, cos for pitch
        else
            set SinPitch to 0
            set CosPitch to 1
        endif
        if (BoatRollAngle != 0)
            SetStage RYB 14 ; Calculate sin, cos for roll
        else
            set SinRoll to 0
            set CosRoll to 1
        endif
    endif

    if (BoatMoving >= 1 || Dragging >= 1 || Resetting >= 1)
        set BoatMarkerZ to BoatZWithRock + BoatMarkerZOffset
        if (Resetting == 2)
            BoatMarker.MoveTo BoatRef
        else
            BoatMarker.MoveTo Player
        endif
		BoatMarker.SetPos x, BoatX
		BoatMarker.SetPos y, BoatY
		BoatMarker.SetPos z, BoatMarkerZ

        if (BoatMoving >= 1)
            if (FrameBoatVelocity > 0)
                set ColliderX to BoatX + (sin * ColliderOffset)
                set ColliderY to BoatY + (cos * ColliderOffset)
            else
                set ColliderX to BoatX - (sin * ColliderOffsetReverse)
                set ColliderY to BoatY - (cos * ColliderOffsetReverse)
            endif

            if (ColliderMoveTimer > 0)
                Set ColliderMoveTimer to ColliderMoveTimer - SecondsPassed
            else
                SetStage RYB 20 ; Enable and position collider
                Set ColliderMoveTimer to ColliderMoveFreq
            endif
        endif
    elseif (BoatMoving == 0 && Dragging == 0 && Summoning == 0 && (PlayerNearBoat == 1 && (RockZOffset != 0 || RockPitchOffset != 0 || RockRollOffset != 0)))
        ; Apply rocking to stationary boat.
        set BoatZWithRock to BoatZ + RockZOffset
        
        BoatRef.SetPos z, BoatZWithRock
        BoatRef.SetAngle x, BoatPitchAngle
        BoatRef.SetAngle y, BoatRollAngle

        set BoatMarkerZ to BoatZWithRock + BoatMarkerZOffset
        BoatMarker.SetPos z, BoatMarkerZ
    endif

    ; Update attachments (seat, chest, lamp, ladder) positions and angles both while moving and stationary (if rocking)
    if (BoatMoving >= 1 || Dragging >= 1 || Resetting >= 1 || (BoatMoving == 0 && Dragging == 0 && (PlayerNearBoat == 1 && (RockZOffset != 0 || RockPitchOffset != 0 || RockRollOffset != 0))))
        SetStage RYB 30 ; Calculate seat position and angle
        SetStage RYB 40 ; Update seat position and angle

        if (ChestPurchased == 1)
            SetStage RYB 31 ; Calculate chest position and angle
            SetStage RYB 41 ; Update chest position and angle
        endif

        if (LampPurchased == 1)
            SetStage RYB 32 ; Calculate lamp(s) position and angle
            SetStage RYB 42 ; Update lamp(s) position and angle
        endif

        if (LadderPurchased == 1 && LadderDeployed == 1)
            SetStage RYB 33 ; Calculate ladder position and angle
            SetStage RYB 43 ; Update ladder position and angle
        endif
    endif

    if (BoatMoving == 1)
        set BoatMoving to 2 ; boat is now fully in motion
    endif
    if (Resetting >= 1)
        set Resetting to 0
    endif
end