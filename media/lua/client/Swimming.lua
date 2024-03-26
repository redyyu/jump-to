
local Swm = {}

Swm.isWaterSquare = function(square)
    if square and square:getFloor() and not square:isFree(false) then -- square is river will not Free.
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


Swm.getWaterSqaureFromWorldObjects = function(worldobjects)
    for _, obj in ipairs(worldobjects) do
        local square = obj:getSquare()
        if square and Swm.isWaterSquare(square) then
            return square
        end
    end
    return nil
end


Swm.findWaterSquares = function(playerObj, radius)
    return RCA.findSquaresRadius(playerObj:getCurrentSquare(), radius, Swm.isWaterSquare)
end


Swm.hasWaterSquareNearby = function(playerObj, radius)
    return Swm.findClosestWaterSquare(playerObj, radius) ~= nil
end


Swm.findClosestWaterSquare = function(playerObj, radius)
    return RCA.findClosestSquareRadius(playerObj:getCurrentSquare(), radius, Swm.isWaterSquare)
end


Swm.startSwimming = function (playerObj)
    if playerObj and playerObj:getPrimaryHandItem() or playerObj:getSecondaryHandItem() then
        if playerObj:getPrimaryHandItem() then
            playerObj:setPrimaryHandItem(nil)
        end
        if playerObj:getSecondaryHandItem() then
            playerObj:setSecondaryHandItem(nil)
        end
        
        local pdata = getPlayerData(playerObj:getPlayerNum())
        if pdata ~= nil then
            pdata.playerInventory:refreshBackpacks()
            pdata.lootInventory:refreshBackpacks()
        end
    end

    local clothes = playerObj:getInventory():getItemsFromCategory("Clothing")
    for i=0, clothes:size() -1 do
        local clothing = clothes:get(i)
        if clothing:isEquipped() and not RCA.BODY_LOCATIONS_MAP[clothing:getBodyLocation()] then
            playerObj:removeWornItem(clothing)
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

Swm.onSwimDrink = function(waterObj, playerObj)
    local waterAvailable = waterObj:getWaterAmount()
	local thirst = playerObj:getStats():getThirst()
	local waterNeeded = math.floor((thirst + 0.005) / 0.1)
	local waterConsumed = math.min(waterNeeded, waterAvailable)
    ISTimedActionQueue.clear(playerObj)  -- make sure drink is current queue.
	ISTimedActionQueue.add(ISSwimTakeWaterAction:new(playerObj, waterConsumed, waterObj, (waterConsumed * 10) + 15))
end


local function formatWaterAmount(setX, amount, max)
	-- Water tiles have waterAmount=9999
	-- Piped water has waterAmount=10000
	if max >= 9999 then
		return string.format("%s: <SETX:%d> %s", getText("ContextMenu_WaterName"), setX, getText("Tooltip_WaterUnlimited"))
	end
	return string.format("%s: <SETX:%d> %d / %d", getText("ContextMenu_WaterName"), setX, amount, max)
end


Swm.doSwimDrinkWaterMenu = function(waterObj, playerObj, context)
	if waterObj:getSquare():getBuilding() ~= playerObj:getBuilding() then return end
	if instanceof(waterObj, "IsoClothingDryer") then return end
	if instanceof(waterObj, "IsoClothingWasher") then return end
	local option = context:addOption(getText("ContextMenu_Drink_Swiming"), waterObj, Swm.onSwimDrink, playerObj)
	local thirst = playerObj:getStats():getThirst()
	local units = math.min(math.ceil(thirst / 0.1), 10)
	units = math.min(units, waterObj:getWaterAmount())
	local tooltip = ISWorldObjectContextMenu.addToolTip()
	local source = getText("ContextMenu_NaturalWaterSource")
	tooltip.description = getText("ContextMenu_WaterSource")  .. ": " .. source .. " <LINE> "
	local tx1 = getTextManager():MeasureStringX(tooltip.font, getText("Tooltip_food_Thirst") .. ":") + 20
	local tx2 = getTextManager():MeasureStringX(tooltip.font, getText("ContextMenu_WaterName") .. ":") + 20
	local tx = math.max(tx1, tx2)
	tooltip.description = tooltip.description .. string.format("%s: <SETX:%d> -%d / %d <LINE> %s",
		getText("Tooltip_food_Thirst"), tx, math.min(units * 10, thirst * 100), thirst * 100,
		formatWaterAmount(tx, waterObj:getWaterAmount(), waterObj:getWaterMax()))
	if waterObj:isTaintedWater() and getSandboxOptions():getOptionByName("EnableTaintedWaterText"):getValue() then
		tooltip.description = tooltip.description .. " <BR> <RGB:1,0.5,0.5> " .. getText("Tooltip_item_TaintedWater")
	end
	option.toolTip = tooltip
end


Swm.onSwimStart = function(playerObj, toSquare, adjacentSquare)
    if adjacentSquare then
        ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, adjacentSquare))
    end

    local shoes = playerObj:getWornItem('Shoes')
    if shoes then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, shoes, 50))
    end

    -- unequip everything not in vanilla bodyloaction map
    -- use to prevent unwanted body mask.
    local clothes = playerObj:getInventory():getItemsFromCategory("Clothing")
    for i=0, clothes:size() -1 do
        local clothing = clothes:get(i)
        if clothing:isEquipped() and not RCA.BODY_LOCATIONS_MAP[clothing:getBodyLocation()] then
            ISTimedActionQueue.add(ISUnequipAction:new(playerObj, clothing, 25))
        end
    end

    local primary = playerObj:getPrimaryHandItem()
    local secondary = playerObj:getSecondaryHandItem()
    if primary then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, primary, 25))
    end
    if secondary and secondary ~= primary then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, secondary, 25))
    end

    ISTimedActionQueue.add(ISSwimInAction:new(playerObj, toSquare))
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

        local body_damage = playerObj:getBodyDamage()
        if body_damage:getWetness() < 100 then
            body_damage:setWetness(body_damage:getWetness() + 15)
        end

        -- onClimateTick is too slow, the native temperature will restore every time.
        -- leave it using onClimateTick, incase want do something with weather.
        -- body_damage:setTemperature(climateManager:getTemperature() - 5)

        local playerInv = playerObj:getInventory()
        local clothingInventory = playerInv:getItemsFromCategory("Clothing")
        for i=0, clothingInventory:size() -1 do
            local clothing = clothingInventory:get(i)
            if clothing:isEquipped() and clothing:getWetness() < 100 then
                clothing:setWetness(clothing:getWetness() + 15)
            end
        end
        
        -- NO NEED those, Wet everything on body
        -- for i=0, clothingInventory:size() -1 do
        --     local clothing = clothingInventory:get(i)
        --     local parts = clothing:getCoveredParts()
        --     if clothing:isEquipped() and parts and parts:size() > 0 then -- make sure is covered body.
        --         -- can not get dirty and wet at same time. dirty it after getting up.
        --         -- if clothing:getDirtyness() < 1 then
        --         --     clothing:setDirtyness(clothing:getDirtyness() + 0.01)
        --         -- end
        --         if clothing:getWetness() < 100 then
        --             clothing:setWetness(clothing:getWetness() + 10)
        --         end
        --     end
        -- end

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
    local joypad_id = playerObj:getJoypadBind()
    if isJoypadPressed(joypad_id, Joypad.RBumper) and 
       (not playerObj:isRunning() and not playerObj:isSprinting()) then
        local waterSquare = Swm.findClosestWaterSquare(playerObj, 2)
        if waterSquare then
            Swm.onSwimStart(playerObj, waterSquare)
        end
        return
    end
    
    local square = playerObj:getCurrentSquare()
    
    if square and Swm.isWaterSquare(square) then
        -- make sure the is in river.
        if not playerObj:getVariableBoolean("isSwimming") then
            playerObj:setVariable("isSwimming", true)
            Swm.startSwimming(playerObj)
        end

        if playerObj:hasTimedActions() then -- Disable all other actions, prevent swith to unwanted animation.
            local queue = ISTimedActionQueue.getTimedActionQueue(playerObj)
            if queue.current.Type ~= 'ISSwimTakeWaterAction' then
                playerObj:Say(getText("IGUI_PlayerText_Cant_Do_Anything_Else_Swimming"))
                ISTimedActionQueue.clear(playerObj)
            end
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
        --     local pdata = getPlayerData(playerObj:getPlayerNum())
        --     if pdata ~= nil then
        --         pdata.playerInventory:refreshBackpacks()
        --         pdata.lootInventory:refreshBackpacks()
        --     end
        -- end
    elseif playerObj:getVariableBoolean("isSwimming") then
        playerObj:setVariable("isSwimming", false)
        ISTimedActionQueue.add(ISSwimOutAction:new(playerObj, Swm.stopSwimming))
        return
    else
        return
    end
end


Swm.onFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    
    if not playerObj or playerObj:getVehicle() then
        -- refused is not vaild scenes.
        return
    end

    if Swm.isWaterSquare(playerObj:getCurrentSquare()) then
        -- remove all context menu since nothing useful, only show description during swimming.
        context:clear()
        -- add Swimming info menu

        local option = context:addOption(getText("ContextMenu_Is_Swimming"))
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setName(getText("Tooltip_Go_Swim"))
        option.toolTip.description = '<RGB:1,0,0> '..getText("Tooltip_Druing_Swimming") .. ' <RGB:1,1,1> <BR>' .. getText("Tooltip_How_To_Swim")
  
        -- add back drink
        local waterObj = nil
        for _, obj in ipairs(worldobjects) do
            if obj:hasWater() then
                waterObj = obj
            end
        end

        if waterObj and getCore():getGameMode() ~= "LastStand"  then
            Swm.doSwimDrinkWaterMenu(waterObj, playerObj, context)
        end

    else
        -- add option if water nearby
        local waterSquare = Swm.getWaterSqaureFromWorldObjects(worldobjects)
        if waterSquare then
            local adjacent = AdjacentFreeTileFinder.Find(square, playerObj)
            local option = context:addOptionOnTop(getText("ContextMenu_Go_Swim"), playerObj, Swm.onSwimStart, waterSquare, adjacent)
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip:setName(getText("Tooltip_Go_Swim"))
            option.toolTip.description = getText("Tooltip_How_To_Swim")

            option.notAvailable = not adjacent
            if option.notAvailable then
                option.toolTip.description = '<RGB:1,0,0> ' .. getText("Tooltip_Unable_Swim") ..' <RGB:1,1,1> <BR>'.. option.toolTip.description
            end
        end
    end
end


Events.OnClimateTick.Add(Swm.onClimateTick)
Events.OnPlayerMove.Add(Swm.onPlayerMove)
Events.OnPlayerUpdate.Add(Swm.onPlayerUpdate)
Events.OnFillWorldObjectContextMenu.Add(Swm.onFillWorldObjectContextMenu)