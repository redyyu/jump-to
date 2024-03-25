
local Stc = {}

Stc.CHAIR_NAMES = {
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


Stc.onSitChair = function(chair, playerObj)

end


Stc.onFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    local chair = nil

    for _, obj in ipairs(worldobjects) do
        local sprite = obj:getSprite()
        if sprite and sprite:getProperties() and sprite:getProperties():Is("CustomName") then
            local custom_name = sprite:getProperties():Val("CustomName")
            if Stc.CHAIR_NAMES[custom_name] then
                chair = obj
                break
            end
        end
    end
    if chair then
        context:addOption(getText("ContextMenu_Sit_Chair"), chair, Stc.onSitChair, playerObj)
    end
end

Events.OnFillWorldObjectContextMenu.Add(Stc.onFillWorldObjectContextMenu)