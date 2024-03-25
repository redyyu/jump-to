
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
    if sprite and sprite:getProperties() then
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

Rch.onSitChair = function(chair, playerObj)
    if chair and playerObj then
        local square = Rch.getSitChairSquare(chair)
        if square then
            ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, square))
        end
        ISTimedActionQueue.add(ISRestOnChairAction:new(playerObj, chair))
    end
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
    local restOpt = context:getOptionFromName(getText("ContextMenu_Rest"))
    if chair then
        if restOpt then
            context:removeOptionByName(restOpt.name)
        end 
        local option = context:addOptionOnTop(getText("ContextMenu_Rest_Chair"), chair, Rch.onSitChair, playerObj)
        option.notAvailable = playerObj:getStats():getEndurance() >= 1
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setName(getText("Tooltip_Rest_On_Chair"))

        local bedType = chair:getProperties():Val("BedType") or "averageBed";
        local bedTypeXln = getTextOrNull("Tooltip_BedType_" .. bedType)
        if bedTypeXln then
            option.toolTip.description = getText("Tooltip_BedType", bedTypeXln)
        end
        
        if option.notAvailable then
            option.toolTip.description = '<RGB:1,0,0> ' .. getText("Tooltip_Rest_NotTiredEnough") ..' <RGB:1,1,1> <BR>'.. option.toolTip.description
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(Rch.onFillWorldObjectContextMenu)