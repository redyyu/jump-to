
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

Swm.startSwimming = function (playerObj)
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
    -- playerObj:getHumanVisual():addBodyVisualFromItemType("RCA.SwimmingBodyMASK")
    -- playerObj:resetModelNextFrame()

    -- Use to hack in water animation
    -- becase didn't find a way to mask the body directly.
    -- add a shadow clothingItem to hack the mask.
    -- the bodylocation must be after another locations. otherwhise might not masking.
    local item = playerObj:getInventory():AddItem("RCA.SwimmingBodyMASK")
    -- activate body mask by wearing the item
    playerObj:setWornItem(item:getBodyLocation(), item)
    local hackItem = playerObj:getInventory():AddItem("RCA.SwimmingRightHandHackingItem")
    playerObj:setPrimaryHandItem(hackItem)
    playerObj:setSecondaryHandItem(hackItem)
    playerObj:setIgnoreAimingInput(true)
    playerObj:setNoClip(true)
end


Swm.stopSwimming = function (playerObj)
    -- playerObj:getHumanVisual():removeBodyVisualFromItemType("RCA.SwimmingBodyMASK")
    -- playerObj:resetModelNextFrame()

    local script_item = ScriptManager.instance:getItem("RCA.SwimmingBodyMASK")
    local item = playerObj:getWornItem(script_item:getBodyLocation())
    if item then
        -- deactivate body mask by unwearing the item
        playerObj:removeWornItem(item)
    end
    playerObj:getInventory():RemoveAll("SwimmingBodyMASK") -- DO NOT add pacakge name
    playerObj:setPrimaryHandItem(nil)
    playerObj:setSecondaryHandItem(nil)
    playerObj:getInventory():RemoveAll("SwimmingRightHandHackingItem") -- DO NOT add pacakge name
    playerObj:setIgnoreAimingInput(false)
    playerObj:setNoClip(false)

    -- stop water sound
    if playerObj:getEmitter():isPlaying('Swimming') then
        playerObj:getEmitter():stopSoundByName('Swimming')
    end
end


Swm.onClimateTick = function(climateManager) -- update character stats, OnPlayerUpdate not fire when game speed up.
    
    local playerObj = getPlayer()
    if playerObj:getVariableBoolean("isSwimming") then

        local stats = playerObj:getStats()
        if stats:getBoredom() > 0 then
            stats:setBoredom(stats:getBoredom() - 1)
        end

        if stats:getEndurance() > 0 then
            stats:setEndurance(stats:getEndurance() - 0.00025)
        end

        -- make happy when swimming.
        local body_damage = playerObj:getBodyDamage()
        if body_damage:getUnhappynessLevel() > 0 then
            body_damage:setUnhappynessLevel(body_damage:getUnhappynessLevel() - 5)
        end

        -- onClimateTick is too slow, the native temperature will restore every time.
        -- leave it using onClimateTick, incase want do something with weather.
        -- body_damage:setTemperature(climateManager:getTemperature() - 5)

        local playerInv = playerObj:getInventory()
        local clothingInventory = playerInv:getItemsFromCategory("Clothing")
        for i=0, clothingInventory:size() -1 do
            local clothing = clothingInventory:get(i)
            if clothing:getWetness() < 100 then
                clothing:setWetness(clothing:getWetness() + 10)
            end

            -- NO NEED those, Wet everything on body
            -- local parts = clothing:getCoveredParts()
            -- if clothing:isEquipped() and parts and parts:size() > 0 then -- make sure is covered body.
            --     -- can not get dirty and wet at same time. dirty it after getting up.
            --     -- if clothing:getDirtyness() < 1 then
            --     --     clothing:setDirtyness(clothing:getDirtyness() + 0.01)
            --     -- end
            --     if clothing:getWetness() < 100 then
            --         clothing:setWetness(clothing:getWetness() + 10)
            --     end
            -- end
        end

	    sendClothing(playerObj)
        triggerEvent("OnClothingUpdated", playerObj)
    end
end


Swm.onPlayerMove = function(playerObj)
    if playerObj:getVariableBoolean("isSwimming") then
        -- keep player alway walking while swimming.
        playerObj:setSneaking(false)
        playerObj:setSprinting(false)
        playerObj:setRunning(false)
    end
end


Swm.onPlayerUpdate = function(playerObj)
    local square = playerObj:getCurrentSquare()

    if square and Swm.isRiverSquare(square) then
        -- make sure the is in river.
        if not playerObj:getVariableBoolean("isSwimming") then
            playerObj:setVariable("isSwimming", true)
            Swm.startSwimming(playerObj)
        end

        if playerObj:hasTimedActions() then -- Disable all other actions, prevent swith to unwanted animation.
            playerObj:Say(getText("IGUI_PlayerText_Cant_Do_Anything_Else_Swimming"))
            ISTimedActionQueue.clear(playerObj)
        end


        -- skil foot step sound play water sound
        if playerObj:getEmitter():isPlaying('HumanFootstepsCombined') then
            playerObj:getEmitter():stopSoundByName('HumanFootstepsCombined')
        end

        if playerObj:isPlayerMoving() then 
            if not playerObj:getEmitter():isPlaying('Swimming') then
                playerObj:getEmitter():playSound('Swimming')
            end
        else
            if playerObj:getEmitter():isPlaying('Swimming') then
                playerObj:getEmitter():stopSoundByName('Swimming')
            end
        end

        -- NO NEED those, clear timedAction take care everything.

        -- local primaryItem = playerObj:getPrimaryHandItem()
        -- local secondayItem = playerObj:getSecondaryHandItem()
        -- if (not primaryItem or primaryItem ~= secondayItem) or 
        --    (primaryItem:getFullType() ~= "RCA.SwimmingHackItem") then
        --     local hackItem = playerObj:getInventory():getFirstType("RCA.SwimmingHackItem")
        --     if not hackItem then
        --         hackItem = playerObj:getInventory():AddItem("RCA.SwimmingHackItem")
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
        Swm.stopSwimming(playerObj)
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
    
    if not Swm.isRiverSquare(square) then
        -- make sure the square is river.
        return
    end

    local is_inwater = Swm.isRiverSquare(playerObj:getCurrentSquare())
    if is_inwater then
        context:clear()  -- move all context menu since nothing useful.
        if not playerObj:isPlayerMoving() then
            square = playerObj:getCurrentSquare()
        else
            square = nil
        end
    end

    local option
    if square then
        option = context:addOptionOnTop(getText("ContextMenu_Go_Swim"), playerObj, Swm.onSwimStart, square)
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setName(getText("Tooltip_Go_Swim"))
        option.toolTip.description = getText("Tooltip_How_To_Swim")

        option.notAvailable = Swm.getDistanceToSquare(playerObj, square) > 3
        if option.notAvailable then
            option.toolTip.description = '<RGB:1,0,0> ' .. getText("Tooltip_Unable_Swim") ..' <RGB:1,1,1> <BR>'.. option.toolTip.description
        end
    else
        -- only show description during swimming.
        option = context:addOption(getText("ContextMenu_Is_Swimming"))
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setName(getText("Tooltip_Go_Swim"))
        option.toolTip.description = getText("Tooltip_How_To_Swim")
    end
end


Events.OnClimateTick.Add(Swm.onClimateTick)
Events.OnPlayerMove.Add(Swm.onPlayerMove)
Events.OnPlayerUpdate.Add(Swm.onPlayerUpdate)
Events.OnFillWorldObjectContextMenu.Add(Swm.onFillWorldObjectContextMenu)