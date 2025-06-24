-- RowYourBoat/scripts/main.lua
local modBaseFormIDs = {
    ["boat"] = 0x0015a8,
    ["lamp_off"] = 0x007dbc,
    ["lamp_on"] = 0x007dbe,
    ["seat"] = 0x003ee1,
    ["chest"] = 0x005451,
    ["ladder"] = 0x006923,
}
local objectClasses = {
    ["boat"] = "BP_MS08Rowboat_C",
    ["lamp_off"] = "BP_ShipLamp01_C",
    ["lamp_on"] = "BP_ShipLamp300_C",
    ["seat"] = "BP_LCStool01F_C",
    ["chest"] = "BP_PCChestClutterLower01_C",
    ["ladder"] = "BP_RopeLadder01_C",
}
local objectClassToTypes = {}
for objectType, className in pairs(objectClasses) do
    objectClassToTypes[className] = objectType
end
local objectPaths = {
    ["boat"] = "/Game/Forms/worldobjects/activator/BP_MS08Rowboat.BP_MS08Rowboat_C",
    ["lamp_off"] = "/Game/Forms/worldobjects/activator/BP_ShipLamp01.BP_ShipLamp01_C",
    ["lamp_on"] = "/Game/Forms/worldobjects/light/BP_ShipLamp300.BP_ShipLamp300_C",
    ["seat"] = "/Game/Forms/worldobjects/furniture/BP_LCStool01F.BP_LCStool01F_C",
    ["chest"] = "/Game/Forms/worldobjects/container/BP_PCChestClutterLower01.BP_PCChestClutterLower01_C",
    ["ladder"] = "/Game/Forms/worldobjects/door/BP_RopeLadder01.BP_RopeLadder01_C",
}
local destroyedObjects = {}
local primaryObjects = {}
local initialized = false

local function log(message)
    print("[RowYourBoat] " .. message .. "\n")
end

-- Extract base ID (last 6 hex digits) from a full FormID
local function GetBaseID(formId)
    if not formId then
        return nil
    end
    -- Mask off the load order bytes (first 2 hex digits)
    return formId & 0xFFFFFF
end

-- Get FormID from a boat
local function GetObjectFormID(object)
    if not object or not object:IsValid() then
        return nil
    end

    local refComponent = object.TESRefComponent
    if not refComponent or not refComponent:IsValid() then
        log("Object does not have a valid TESRefComponent")
        return nil
    end

    return tonumber(refComponent.FormIDInstance)
end

-- Check if a object matches a specific base ID
local function MatchesBaseID(object, baseId, objectType)
    if not baseId then
        return false
    end
    
    local formId = GetObjectFormID(object)
    if not formId then
        return false
    end
    
    local objectBaseId = GetBaseID(formId)
    log(string.format(string.upper(objectType) .. " Object FormID: %x, BaseID: %x == %x", formId, objectBaseId, baseId))
    return objectBaseId == baseId
end

-- Check if a boat is our mod-added boat
local function IsModObject(object, objectType)
    return MatchesBaseID(object, modBaseFormIDs[objectType], objectType)
end

-- Check if a actor object is valid and should be considered
local function IsActorValid(object)
    if not object or not object:IsValid() then
        return false
    end
    
    -- Check if we've already destroyed this object
    local objectId = tostring(object)
    if destroyedObjects[objectId] then
        return false
    end
    
    -- Skip default objects
    local fullName = object:GetFullName()
    if string.find(fullName, "Default__") then
        return false
    end
    
    if object.bHidden == true or object.bActorIsBeingDestroyed == true then
        return false
    end
    
    return true
end

-- Find all valid objects of type
local function FindAllObjects(objectType)
    local objects = {}
    local class = objectClasses[objectType] 
    local allObjects = FindAllOf(tostring(class))
    
    if allObjects then
        for i, object in pairs(allObjects) do
            if IsActorValid(object) then
                table.insert(objects, object)
            end
        end
    end
    
    return objects
end

-- Set or validate the primary object
local function SetPrimaryObject(objects, objectType)
    local primaryObject = primaryObjects[objectType]
    -- If we already have a primary object and it's still valid, keep it
    if primaryObject and primaryObject:IsValid() and IsActorValid(primaryObject) then
        log(string.upper(objectType) .. " Primary object already set and valid: " .. primaryObject:GetFullName())
        return
    end
    
    -- Find the first valid mod object to be our primary
    for _, object in ipairs(objects) do
        primaryObjects[objectType] = object
        log(string.upper(objectType) .. " Set primary mod object: " .. object:GetFullName())
        break
    end
end

local function DestroyObject(object, objectType)
    if not object or not object:IsValid() then
        return
    end
    
    local objectId = tostring(object)
    local objectName = object:GetFullName()
    
    -- Mark as destroyed first
    destroyedObjects[objectId] = true
    
    -- Hide and disable
    local success = pcall(function()
        object:SetActorHiddenInGame(true)
        object:SetActorEnableCollision(false)
        
        if object.SetActorTickEnabled then
            object:SetActorTickEnabled(false)
        end
        
        object:K2_DestroyActor()
    end)
    
    if success then
        log(string.upper(objectType) .. " Destroyed duplicate: " .. objectName)
    else
        log(string.upper(objectType) .. " Failed to destroy object: " .. objectName .. " - " .. tostring(object))
    end
end

-- Clean up duplicate objects for type
local function CleanupDuplicatesOfType(objectType)
    log(string.upper(objectType) .. " CleanupDuplicatesOfType")
    local objects = FindAllObjects(objectType)
    log(string.upper(objectType) .. " Found " .. #objects .. " objects of type")
    
    -- Count and collect mod objects
    local modObjects = {}
    for _, object in ipairs(objects) do
        if IsModObject(object, objectType) then
            table.insert(modObjects, object)
        end
    end
    log(string.upper(objectType) .. " Found " .. #modObjects .. " mod objects")

    -- Set or validate primary object
    SetPrimaryObject(modObjects, objectType)
    
    -- If we have no duplicates, nothing to do
    if #modObjects <= 1 then
        if #modObjects == 0 then
            log(string.upper(objectType) .. " No mod objects found, nulling primary object")
            primaryObjects[objectType] = nil  -- Reset if no mod boats exist
        end
        return
    end
    
    log(string.upper(objectType) .. " Found " .. #modObjects .. " mod objects, deleting primary one")
    
    -- Delete all mod objects except the primary one
    local removedCount = 0
    local primaryModObject = primaryObjects[objectType]
    if primaryModObject and primaryModObject:IsValid() then
        for _, object in ipairs(modObjects) do
            log(string.upper(objectType) .. " Object name: " .. object:GetFullName() .. " primaryObject name: " .. (primaryModObject and primaryModObject:GetFullName()) or "nil")
            if object:GetFullName() == primaryModObject:GetFullName() then
                DestroyObject(object, objectType)
                removedCount = removedCount + 1
            end
        end
    end
    
    if removedCount > 0 then
        log(string.upper(objectType) .. " Cleaned up " .. removedCount .. " duplicate object(s)")
    end
end

-- Clean up duplicate objects
local function CleanupDuplicates()
    for objectType, _ in pairs(objectClasses) do
        CleanupDuplicatesOfType(objectType)
    end
end

local function detectAndDeleteDuplicateObject(object, objectType)
    local attempts = 0
    local maxAttempts = 100 -- 100ms total timeout

    if not object or not object:IsValid() then
        log(string.upper(objectType) .. " Object is not valid, skipping")
        return false -- Skip invalid objects
    end

    local fullName = object:GetFullName()
    if string.find(fullName, "Default__") or string.find(fullName, "_Generated_") then
        log(string.upper(objectType) .. " Skipping default or generated object: " .. fullName)
        return false -- Skip default or generated objects which are guaranteed to not be what we are looking for
    end

    local function waitForFormId()
        local formId = GetObjectFormID(object)
        if formId and formId ~= 0 then
            log(string.upper(objectType) .. " Found object FormID in attempts: " .. attempts)
            if IsModObject(object, objectType) then
                log(string.upper(objectType) .. " New mod object detected: " .. object:GetFullName())
                local primaryObject = primaryObjects[objectType]
                if primaryObject and primaryObject:IsValid() and IsActorValid(primaryObject) then
                    log(string.upper(objectType) .. " Delete old primary object: " .. primaryObject:GetFullName())
                    DestroyObject(primaryObject, objectType)
                    log(string.upper(objectType) .. " Setting new primary object: " .. object:GetFullName())
                    primaryObjects[objectType] = object
                else
                    log(string.upper(objectType) .. " No current primary object, setting primary: " .. object:GetFullName())
                    primaryObjects[objectType] = object
                end
            end
        elseif attempts < maxAttempts and object and object:IsValid() then
            attempts = attempts + 1
            ExecuteWithDelay(1, waitForFormId) -- Check again after 1ms
        else
            log(string.upper(objectType) .. " Failed to get FormID for new object after 100 attempts")
        end
    end
    waitForFormId()
end

NotifyOnNewObject("/Script/Engine.Actor", function(object)
    local objectName = object:GetFullName()
    local className = string.match(objectName, "^([^%s]+)")
    local objectType = objectClassToTypes[className]
    if objectType then
        log(string.upper(objectType) .. " Detected spawned object: " .. objectName)
        detectAndDeleteDuplicateObject(object, objectType)
    end
end)

-- -- Manual cleanup hotkey
-- RegisterKeyBind(Key.K, {ModifierKey.CONTROL}, function()
--     log("Manual cleanup triggered")
--     CleanupDuplicates()
-- end)

-- -- Debug key to reset primary boat
-- RegisterKeyBind(Key.K, {ModifierKey.ALT}, function()
--     log("Resetting primary boat")
--     primaryObjects = {}
--     destroyedObjects = {}
--     CleanupDuplicates()
-- end)

log("Script loaded!")
-- log("  CTRL-K = Manual cleanup (with debug info)")
-- log("  ALT-K = Reset primary boat selection")