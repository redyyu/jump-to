require "Vehicles/ISUI/VehicleMenu"
require "luautils"

-- Add the Push options to the outside vehicle menu
-- Requires at least 3 str to consider it and then scale based on vehicle weight
--

local function getPushPos(vehicle, pushDirection, posVector)
    local halfLen = vehicle:getScript():getPhysicsChassisShape():z() / 2
    local halfWidth = vehicle:getScript():getPhysicsChassisShape():x() / 2
    local x, z = 0, 0

    local pushAction = {
        ['Front'] = function() 
            z, x = halfLen, 0 end,
        ['Rear'] = function()
            z, x = -halfLen, 0 end,

        ['LeftFront'] = function()
            z, x = halfLen*0.7, halfWidth end,
        ['LeftRear'] = function()
            z, x = -halfLen*0.7, halfWidth end,

        ['RightFront'] = function()
            z, x = halfLen*0.7, -halfWidth end,
        ['RightRear'] = function()
            z, x = -halfLen*0.7, -halfWidth end,
    }
    
    pushAction[pushDirection]()

    return vehicle:getWorldPos(x, 0 ,z, posVector)
end


local PshCar = {}
PshCar.minStrengthLevel = 3
PshCar.posVector = Vector3f.new()

PshCar.onPushVehicle = function(playerObj, vehicle, pushDirection)

    local v_pos = getPushPos(vehicle, pushDirection, PshCar.posVector)

    -- Queue up the movement action
    local action = ISPathFindAction:pathToLocationF(playerObj, v_pos:x(), v_pos:y(), v_pos:z())
	action:setOnFail(PshCar.onPushVehiclePathFail, playerObj)
	ISTimedActionQueue.add(action)

    -- Queue up unequipping any hand items
    local equipped = playerObj:getPrimaryHandItem()
    if equipped ~= nil then
        ISTimedActionQueue.add(ISUnequipAction:new(playerObj, equipped, 15))
    end

    -- Then shove the vehicle
    ISTimedActionQueue.add(ISPushVehicleAction:new(playerObj, vehicle, pushDirection))
end


PshCar.onPushVehiclePathFail = function(playerObj) 
    playerObj:Say(getText("IGUI_PLAYER_TEXT_CANT_REACH_VEHICLE"))
end


PshCar.doPushVehicleMenu = function(playerObj, context, vehicle)
    -- Only draw the submenu if they meet the strength requirements
    -- Otherwise show the menu item but red with a tooltip
    
    local pushOption = context:addOption(getText("ContextMenu_Push_Vehicle"), nil, nil)
    local tooltip = ISWorldObjectContextMenu.addToolTip()

    local str_level = player:getPerkLevel(Perks.Strength)
    local vehicle_weight = vehicle:getMass()
    local str_require = PshCar.minStrengthLevel + math.floor(vehicleWeight / 800)
    if str_level >= str_require then
        toolTip.description = " <RGB:0,1,0>" .. getText("IGUI_perks_Strength") .. ":" .. str_level .. "/" .. str_require .. " <LINE>"

        local subMenuMain = ISContextMenu:getNew(context)
        context:addSubMenu(pushOption, subMenuMain)

        local leftOption = subMenuMain:addOption(getText("ContextMenu_Push_Vehicle_FROMLEFT"))
        local subMenuLeft = ISContextMenu:getNew(context)

        context:addSubMenu(leftOption, subMenuLeft)
        subMenuLeft:addOption(getText("ContextMenu_Push_Vehicle_FROMFRONT"), playerObj, PshCar.onPushVehicle, vehicle, 'LeftFront')
        subMenuLeft:addOption(getText("ContextMenu_Push_Vehicle_FROMREAR"), playerObj, PshCar.onPushVehicle, vehicle, 'LeftRear')

        local rightOption = subMenuMain:addOption(getText("ContextMenu_Push_Vehicle_FROMRIGHT"))
        local subMenuRight = ISContextMenu:getNew(context)

        context:addSubMenu(rightOption, subMenuRight)
        subMenuRight:addOption(getText("ContextMenu_Push_Vehicle_FROMFRONT"), playerObj, PshCar.onPushVehicle, vehicle, 'RightFront')
        subMenuRight:addOption(getText("ContextMenu_Push_Vehicle_FROMREAR"), playerObj, PshCar.onPushVehicle, vehicle, 'RightRear')

        subMenuMain:addOption(getText("ContextMenu_Push_Vehicle_FROMFRONT"), playerObj, PshCar.onPushVehicle, vehicle, 'Front')
        subMenuMain:addOption(getText("ContextMenu_Push_Vehicle_FROMREAR"), playerObj, PshCar.onPushVehicle, vehicle, 'Rear')
    else
        toolTip.description = " <RGB:1,0,0>" .. getText("IGUI_perks_Strength") .. ":" .. str_level .. "/" .. str_require .. " <LINE>"
        pushOption.notAvailable = true
    end
end


PshCar.onfillMenuOutsideVehicleMenu = function(playerNum, context, vehicle, test)
    local playerObj = getSpecificPlayer(playerNum)
    if not playerObj:getVehicle() then
        local vehicle = RCA.pickVehicle(playerNum)
        if vehicle then
            return PshCar.doPushVehicleMenu(playerObj, context, vehicle)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(PshCar.onfillMenuOutsideVehicleMenu)