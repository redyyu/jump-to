
local Rch = {}

Rch.CHAIR_NAMES = {
    ["Chair"] = true, 
    ["Couch"] = true, 
    ["Funton"] = true, 
    ["Bench"] = true, 
    ["Church"] = true, 
    ["Blue Bar Stool"] = true, 
    ["Bar Stool"] = true, 
    ["Stool"] = true, 
    ["Seat"] = true,
}

Rch.getSitChairSquare = function(chair)
    local sprite = chair:getSprite()
    local chairSquare = chair:getSquare()
    local sitSquare = nil
    
    if chairSquare:isFree(false) then
        sitSquare = chairSquare
    
    elseif sprite and sprite:getProperties() then
        local props = sprite:getProperties()
        local facing = props:Val("Facing")
        if facing == "S" then
            sitSquare = chairSquare:getAdjacentSquare(IsoDirections.S)
        elseif facing == "E" then
            sitSquare = chairSquare:getAdjacentSquare(IsoDirections.E)
        elseif facing == "W" then
            sitSquare = chairSquare:getAdjacentSquare(IsoDirections.W)
        elseif facing == "N" then
            sitSquare = chairSquare:getAdjacentSquare(IsoDirections.N)
        end
    end
    return sitSquare
end

Rch.onSitChair = function(chair, playerObj, sitSquare)
    if chair:getSquare() and sitSquare and playerObj:getCurrentSquare() then
        ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sitSquare))
        ISTimedActionQueue.add(ISRestOnChairAction:new(playerObj, chair, sitSquare))
    end
end


local function getMoveableDisplayName(obj)
	if not obj then return nil end
	if not obj:getSprite() then return nil end
	local props = obj:getSprite():getProperties()
	if props:Is("CustomName") then
		local name = props:Val("CustomName")
		if props:Is("GroupName") then
			name = props:Val("GroupName") .. " " .. name
		end
		return Translator.getMoveableDisplayName(name)
	end
	return nil
end

Rch.onFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    local chair = nil

    for _, obj in ipairs(worldobjects) do
        local sprite = obj:getSprite()
        if sprite and sprite:getProperties() and sprite:getProperties():Is("CustomName") then
            local custom_name = sprite:getProperties():Val("CustomName")
            if Rch.CHAIR_NAMES[custom_name] then
                chair = obj
                break
            end
        end
    end

    if chair then
        if not SandboxVars.RefinedCharacterActions.VanillaRestforChairEnabled and not isDebugEnabled() then
            context:removeOptionByName(getText("ContextMenu_Rest"))
        end

        local chair_name = getMoveableDisplayName(chair)
        local optionName = getText("ContextMenu_Rest_Chair", chair_name)
        if playerObj:getStats():getEndurance() >= 1 then
            optionName = getText("ContextMenu_Sit_Chair", chair_name)
        end
        local sitSquare = Rch.getSitChairSquare(chair)
        local option = context:addOptionOnTop(optionName, chair, Rch.onSitChair, playerObj, sitSquare)

        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setName(getText("Tooltip_Rest_On_Chair", chair_name))

        local bedType = chair:getProperties():Val("BedType") or "averageBed";
        local bedTypeXln = getTextOrNull("Tooltip_BedType_" .. bedType)
        if bedTypeXln then
            option.toolTip.description = getText("Tooltip_BedType", bedTypeXln)
        end
        
        option.notAvailable = not (sitSquare and sitSquare:isFree(false) and 
                                   AdjacentFreeTileFinder.privTrySquare(playerObj:getCurrentSquare(), sitSquare))
        if option.notAvailable then
            option.toolTip.description = '<RGB:1,0,0> ' .. getText("Tooltip_Unable_Sit", chair_name) ..' <RGB:1,1,1> <BR>'.. option.toolTip.description
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(Rch.onFillWorldObjectContextMenu)