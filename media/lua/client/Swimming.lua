
local Swm = {}


Swm.getDistanceToSquare = function(playerObj, square)
    local x1 = playerObj:getX()
    local x2 = square:getX()
    local y1 = playerObj:getY()
    local y2 = square:getY()
    return math.sqrt(math.pow((y2-y1), 2) + math.pow((x2-x1), 2)) 
end


Swm.isRiverSquare = function(square)
    if square and not square:isFree(false) then  -- square is river will not Free.
        local sprite = square:getFloor():getSprite()
        if sprite and sprite:getProperties() then
            return sprite:getProperties():Is(IsoFlagType.water)
        else
            return false
        end
    else
        return false
    end
end

Swm.setSwimming = function (playerObj)
    if playerObj and playerObj:getPrimaryHandItem() or playerObj:getSecondaryHandItem() then
        if playerObj:getPrimaryHandItem() then
            playerObj:setPrimaryHandItem(nil)
        end
        if playerObj:getSecondaryHandItem() then
            playerObj:setSecondaryHandItem(nil)
        end
        
        local pdata = getPlayerData(playerObj:getPlayerNum());
        if pdata ~= nil then
            pdata.playerInventory:refreshBackpacks()
            pdata.lootInventory:refreshBackpacks()
        end
    end

    -- Seems its not working.
    -- playerObj:getHumanVisual():addBodyVisualFromItemType("ECA.SwimmingBodyMASK")
    -- playerObj:resetModelNextFrame()

    -- Use to hack in water animation
    -- becase didn't find a way to mask the body directly.
    -- add a shadow clothingItem to hack the mask.
    -- the bodylocation must be after another locations. otherwhise might not masking.
    local item = playerObj:getInventory():AddItem("ECA.SwimmingBodyMASK")
    playerObj:setWornItem(item:getBodyLocation(), item)
    local hackItem = playerObj:getInventory():AddItem("ECA.SwimmingHackItem")
    playerObj:setPrimaryHandItem(hackItem)
    playerObj:setSecondaryHandItem(hackItem)
    playerObj:setIgnoreAimingInput(true)
    playerObj:setNoClip(true)
end


Swm.unsetSwimming = function (playerObj)
    -- playerObj:getHumanVisual():removeBodyVisualFromItemType("ECA.SwimmingBodyMASK")
    -- playerObj:resetModelNextFrame()

    local script_item = ScriptManager.instance:getItem("ECA.SwimmingBodyMASK")
    local item = playerObj:getWornItem(script_item:getBodyLocation())
    playerObj:removeWornItem(item)
    playerObj:getInventory():RemoveAll("SwimmingBodyMASK")
    playerObj:setPrimaryHandItem(nil)
    playerObj:setSecondaryHandItem(nil)
    playerObj:getInventory():RemoveAll("ECA.SwimmingHackItem")
    playerObj:setIgnoreAimingInput(false)
    playerObj:setNoClip(false)
end

Swm.onPlayerMove = function(playerObj)
    if playerObj:getVariableBoolean("isSwimming") then
        -- keep player alway running while swimming
        -- because the `walkSwim` anim set won't moving. 
        playerObj:setSneaking(false)
        playerObj:setRunning(true)
    end
end


Swm.onPlayerUpdate = function(playerObj)
    local square = playerObj:getCurrentSquare()

    if square and Swm.isRiverSquare(square) then
        -- make sure the is in river.
        if not playerObj:getVariableBoolean("isSwimming") then
            playerObj:setVariable("isSwimming", true)
            Swm.setSwimming(playerObj)
        end
        
        if playerObj:getEmitter():isPlaying('HumanFootstepsCombined') then
            playerObj:getEmitter():stopSoundByName('HumanFootstepsCombined')
        end
        if not playerObj:getEmitter():isPlaying('WashClothing') and playerObj:isMoving() then
            playerObj:getEmitter():playSound('WashClothing')
        end

        if playerObj:hasTimedActions() then
            playerObj:Say(getText("IGUI_PlayerText_Cant_Do_While_Swimming"))
            ISTimedActionQueue.clear(playerObj)
        end

        -- NO NEED those, clear timedAction take care everything.

        -- local primaryItem = playerObj:getPrimaryHandItem()
        -- local secondayItem = playerObj:getSecondaryHandItem()
        -- if (not primaryItem or primaryItem ~= secondayItem) or 
        --    (primaryItem:getFullType() ~= "ECA.SwimmingHackItem") then
        --     local hackItem = playerObj:getInventory():getFirstType("ECA.SwimmingHackItem")
        --     if not hackItem then
        --         hackItem = playerObj:getInventory():AddItem("ECA.SwimmingHackItem")
        --     end
        --     playerObj:setPrimaryHandItem(hackItem)
        --     playerObj:setSecondaryHandItem(hackItem)
        --     local pdata = getPlayerData(playerObj:getPlayerNum());
        --     if pdata ~= nil then
        --         pdata.playerInventory:refreshBackpacks()
        --         pdata.lootInventory:refreshBackpacks()
        --     end
        -- end
    elseif playerObj:getVariableBoolean("isSwimming") then
           playerObj:setVariable("isSwimming", false)
        Swm.unsetSwimming(playerObj)
        return
    else
        return
    end
end


Swm.onSwimStart = function(playerObj, toSquare)
    playerObj:setX(toSquare:getX())
    playerObj:setY(toSquare:getY())
end


Swm.onFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    
    if not playerObj or playerObj:getVehicle() or playerObj:getZ() > 0 then
        -- refused is not vaild scenes.
        return
    end

    local square = nil
    for i, v in ipairs(worldobjects) do
        if v and v:getSquare() then
            square = v:getSquare()
        end
    end

    if not square or not Swm.isRiverSquare(square) or Swm.isRiverSquare(playerObj:getCurrentSquare()) then
        -- make sure the square is river.
        return
    end

    local option = context:addOptionOnTop(getText("ContextMenu_Swim"), playerObj, Swm.onSwimStart, square)
    option.toolTip = ISWorldObjectContextMenu.addToolTip()
    option.toolTip:setName(getText("Tooltip_Go_Swim"))
    option.toolTip.description = getText("Tooltip_How_To_Swim")

    option.notAvailable = Swm.getDistanceToSquare(playerObj, square) > 2
    if option.notAvailable then
        option.toolTip.description = '<RGB:1,0,0> ' .. getText("Tooltip_Unable_To_Swim") ..' <RGB:1,1,1> <BR>'.. option.toolTip.description
    end
end

Events.OnPlayerMove.Add(Swm.onPlayerMove)
Events.OnPlayerUpdate.Add(Swm.onPlayerUpdate)
Events.OnFillWorldObjectContextMenu.Add(Swm.onFillWorldObjectContextMenu)