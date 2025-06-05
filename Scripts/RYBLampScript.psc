ScriptName RYBLampScript

begin OnActivate
    if (RYB.LampOn == 0)
        set RYB.LampOn to 1
    else
        set RYB.LampOn to 0
    endif
end

begin OnMagicEffectHit FIDG
    set RYB.LampOn to 1
end

begin OnMagicEffectHit FRDG
    set RYB.LampOn to 0
end