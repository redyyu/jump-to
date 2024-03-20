
local Jmp = {}
Jmp.minZ = 0
Jmp.distanceBase = 1.0
Jmp.enduranceLevelThreshold = 2
Jmp.heavyloadLevelThreshold = 2
Jmp.key = 'Crouch'  -- for keep KEY binds Vanilla, `Crouch` is best option, it's looks like prepare to jump.


Jmp.getJumpDistance = function(playerObj)
    if playerObj:getMoodles():getMoodleLevel(MoodleType.Endurance) > Jmp.enduranceLevelThreshold or
       playerObj:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) > Jmp.heavyloadLevelThreshold then
        return 0
    end
    
    local modifier = playerObj:getPerkLevel(Perks.Fitness) + playerObj:getPerkLevel(Perks.Sprinting)

    if playerObj:isSprinting() then
        modifier = modifier * 2
    elseif playerObj:isRunning() then
        modifier = modifier * 1.5
    end

    local heavy_load = playerObj:getMoodles():getMoodleLevel(MoodleType.HeavyLoad)
    modifier = modifier - heavy_load * 0.25

    if playerObj:getTraits():contains("Obese") then
        modifier = modifier * 0.55
    elseif playerObj:getTraits():contains("Overweight") then
        modifier = modifier * 0.75
    end

    local stats = playerObj:getStats()
    local endurance = stats:getEndurance()
    local fatigue = stats:getFatigue()
    local pain = stats:getPain()
    local sickness = stats:getSickness()
    
    modifier = modifier * (endurance - pain - fatigue - sickness)

    local distance =  (Jmp.distanceBase + modifier / 5) 

    return distance
end


local relatedBodyPart = {
    BodyPartType.Torso_Lower, BodyPartType.Groin,
    BodyPartType.UpperLeg_L, BodyPartType.UpperLeg_R,
    BodyPartType.LowerLeg_L, BodyPartType.LowerLeg_R,
    BodyPartType.Foot_L, BodyPartType.Foot_R
}

Jmp.isRelatedBodyPartDamaged = function(playerObj)
    local body_damage = playerObj:getBodyDamage()
    if body_damage then
        for _, bp_type in ipairs(relatedBodyPart) do
            local body_part = body_damage:getBodyPart(bp_type)
            if body_part:getFractureTime() > 0.0F or 
               body_part:isDeepWounded() or 
               body_part:getStiffness() >= 50.0 then
                return true
            end
        end
    end

    return false
end


Jmp.getDestSquare = function(playerObj, distance)
    -- Credit: Tchernobill
    local orient_angle = playerObj:getAnimAngleRadians() 
    --0 = East, PI/2 = South, -PI/2=North, PI=West
    local destX = playerObj:getX() + math.cos(orient_angle) * distance
    local destY = playerObj:getY() + math.sin(orient_angle) * distance

    local z = playerObj:getZ()
    local dest_square = nil
    while z >= Jmp.minZ and not dest_square do
        dest_square = getCell():getGridSquare(destX, destY, z)
        z = z - 1
    end

    return dest_square
end


Jmp.onJumpStart = function(playerObj)
    if not playerObj or playerObj:hasTimedActions() or playerObj:getVehicle() then
        -- refused is not vaild scenes.
        return
    end

    if playerObj:getSquare() and playerObj:getSquare():HasStairs() then
        -- refused when player on stairs, that will cause strange anim.
        -- but pass if player not on a square, allow player to jump off it.
        -- etc. teleport to a none square coordinate.
        return
    end

    if playerObj:isbFalling() or
       not playerObj:isCurrentState(IdleState.instance()) or 
       Jmp.isRelatedBodyPartDamaged(playerObj) then
        -- refused when player already falling. or body part relate to jump is damaged.
        -- or player is doing something else.
        return
    end
    local distance = Jmp.getJumpDistance(playerObj)
    if distance ~= nil then
        local dest_square = Jmp.getDestSquare(playerObj, distance)
        if dest_square then
            ISTimedActionQueue.clear(playerObj)
            ISTimedActionQueue.add(ISJumpToAction:new(playerObj, dest_square, distance))
        end
    end

end


Jmp.onPlayerUpdate = function(playerObj)
    -- support joypad, they might diffcult to using context menu.
    -- untested might not work.
    local joypad_id = playerObj:getJoypadBind()
    if isJoypadPressed(joypad_id, Joypad.RBumper) then
        if playerObj:isRunning() or playerObj:isSprinting() then
            Jmp.onJumpStart(playerObj)
        end
    end
end


Jmp.onKeyStartPressed = function(key)
    if SandboxVars.JumptoMenu.KeyPressToJumpDisabled then
        return
    end

    if key == getCore():getKey(Jmp.key) then
        local playerObj = getPlayer()
        if playerObj:isRunning() or playerObj:isSprinting() then
            Jmp.onJumpStart(playerObj)
        end
    end
end


Jmp.onJumpCursor = function(playerNum)
    local playerObj = getSpecificPlayer(playerNum)
	local bo = ISJumpToCursor:new("", "", playerObj, Jmp.getJumpDistance)
	getCell():setDrag(bo, playerNum)
end


Jmp.onFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    
    if not playerObj or playerObj:hasTimedActions() or playerObj:getVehicle() then
        -- refused is not vaild scenes.
        return
    end

    if playerObj:getSquare() and playerObj:getSquare():HasStairs() then
        -- refused when player on stairs, that will cause strange anim.
        -- but pass if player not on a square, allow player to jump off it.
        -- etc. teleport to a none square coordinate.
        return
    end

    if playerObj:isbFalling() or
       not playerObj:isCurrentState(IdleState.instance()) or 
       Jmp.isRelatedBodyPartDamaged(playerObj) then
        -- refused when player already falling. or body part relate to jump is damaged.
        -- or player is doing something else.
        return
    end

    local option = context:addOptionOnTop(getText("ContextMenu_Jumpto"), playerNum, Jmp.onJumpCursor)
    option.toolTip = ISWorldObjectContextMenu.addToolTip()
    option.toolTip:setName(getText("ContextMenu_Jumpto"))
    option.toolTip.description = getText("Tooltip_How_To_Jump")
end


Events.OnPlayerUpdate.Add(Jmp.onPlayerUpdate)
Events.OnKeyStartPressed.Add(Jmp.onKeyStartPressed)
Events.OnFillWorldObjectContextMenu.Add(Jmp.onFillWorldObjectContextMenu)