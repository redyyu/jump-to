
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


Rch.onSitChair = function(chair, playerObj)
    if luautils.walkAdj(playerObj, chair:getSquare()) then
        ISTimedActionQueue.add(ISRestOnChairAction:new(playerObj))
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
    if chair and restOpt then
        context:insertOptionBefore(restOpt.name, getText("ContextMenu_Rest_Chair"), chair, Rch.onSitChair, playerObj)
        context:removeOptionByName(restOpt.name)
    end
end

Events.OnFillWorldObjectContextMenu.Add(Rch.onFillWorldObjectContextMenu)