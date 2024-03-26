
local CHAIR_NAMES = {
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

local function getSitChairSquare(chair, playerObj)
    if not chair then
        return nil
    end

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

    if sitSquare and not AdjacentFreeTileFinder.privTrySquare(playerObj:getCurrentSquare(), sitSquare) then 
        sitSquare = nil
    end

    return sitSquare
end


local function isChair(obj)
    local sprite = obj:getSprite()
    if sprite and sprite:getProperties() and sprite:getProperties():Is("CustomName") then
        return CHAIR_NAMES[sprite:getProperties():Val("CustomName")]
    end
    return false
end


local function isChairReachable(obj, square, playerObj)
    if isChair(obj) and AdjacentFreeTileFinder.privTrySquare(playerObj:getCurrentSquare(), square) then
        return true
    else
        return false
    end
end    


local SitOnChair = {}

SitOnChair.onReadSitChair = function(chair, playerObj, sitSquare, books)
    if chair:getSquare() and sitSquare and playerObj:getCurrentSquare() then
        ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sitSquare))
        for _, book in ipairs(books) do
            print(book)
            print("book============================================")
            ISTimedActionQueue.add(ISSitOnChairAction:new(playerObj, chair, sitSquare, book))
        end
        ISTimedActionQueue.add(ISSitOnChairAction:new(playerObj, chair, sitSquare))
    end
end


SitOnChair.onSitChair = function(chair, playerObj, sitSquare)
    if chair:getSquare() and sitSquare and playerObj:getCurrentSquare() then
        ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, sitSquare))
        ISTimedActionQueue.add(ISSitOnChairAction:new(playerObj, chair, sitSquare))
    end
end



SitOnChair.onFillInventoryObjectContextMenu = function(playerNum, context, items)
    local playerObj = getSpecificPlayer(playerNum)
    local items = ISInventoryPane.getActualItems(items)

    if not playerObj or playerObj:getVehicle() then
        -- refused is not vaild scenes.
        return
    end

    local books = {}
    for _, item in ipairs(items) do
        if instanceof(item, 'Literature') then
            table.insert(books, item)
        end
    end

    local chair = RCA.findOneWorldObjectNearby(playerObj:getCurrentSquare(), 3, isChairReachable, playerObj)

    if #books > 0 and chair then
        local chair_name = RCA.getMoveableDisplayName(chair)
        local sitSquare = getSitChairSquare(chair, playerObj)
        local readOpt = context:getOptionFromName(getText("ContextMenu_Read"))
        local option = context:insertOptionBefore(readOpt.name, getText("ContextMenu_Read_On_Chair", chair_name), 
                                                  chair, SitOnChair.onReadSitChair, playerObj, sitSquare, books)
        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setName(getText("Tooltip_Read_Book_On_Chair", chair_name))
        if not sitSquare then
            option.notAvailable = true
            option.toolTip.description = '<RGB:1,0,0> ' .. getText("Tooltip_Unable_Sit", chair_name) ..' <RGB:1,1,1>'
        elseif playerObj:isAsleep() then
            option.notAvailable = true
            option.toolTip.description ='<RGB:1,0,0> ' .. getText("ContextMenu_NoOptionSleeping") ..' <RGB:1,1,1>'
        end
    end
end


SitOnChair.onFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    local chair = nil
    
    if not playerObj or playerObj:getVehicle() then
        -- refused is not vaild scenes.
        return
    end

    for _, obj in ipairs(worldobjects) do
        if isChair(obj) then
            chair = obj
        end
    end

    if chair then
        if not SandboxVars.RefinedCharacterActions.VanillaRestforChairEnabled and not isDebugEnabled() then
            context:removeOptionByName(getText("ContextMenu_Rest"))
        end

        local chair_name = RCA.getMoveableDisplayName(chair)
        local optionName = getText("ContextMenu_Rest_Chair", chair_name)
        if playerObj:getStats():getEndurance() >= 1 then
            optionName = getText("ContextMenu_Sit_Chair", chair_name)
        end
        local sitSquare = getSitChairSquare(chair, playerObj)
        local option = context:addOptionOnTop(optionName, chair, SitOnChair.onSitChair, playerObj, sitSquare)

        option.toolTip = ISWorldObjectContextMenu.addToolTip()
        option.toolTip:setName(getText("Tooltip_Rest_On_Chair", chair_name))

        local bedType = chair:getProperties():Val("BedType") or "averageBed";
        local bedTypeXln = getTextOrNull("Tooltip_BedType_" .. bedType)
        if bedTypeXln then
            option.toolTip.description = getText("Tooltip_BedType", bedTypeXln)
        end
        
        option.notAvailable = not sitSquare
        if option.notAvailable then
            option.toolTip.description = '<RGB:1,0,0> ' .. getText("Tooltip_Unable_Sit", chair_name) ..' <RGB:1,1,1> <BR>'.. option.toolTip.description
        end
    end
end


Events.OnFillInventoryObjectContextMenu.Add(SitOnChair.onFillInventoryObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(SitOnChair.onFillWorldObjectContextMenu)