local MODAL_WIDTH = 400
local MODAL_HEIGHT = 140

local GunSuicide = {}


GunSuicide.suicideGun = function(dummy, button, playerObj, gun)
    if button.internal == "NO" then return end
    
    ISInventoryPaneContextMenu.equipWeapon(gun, true, false, playerObj:getPlayerNum())
    ISTimedActionQueue.add(ISGunSuicide:new(playerObj, gun))
end


GunSuicide.onGunSuicide = function(playerObj, gun)
    local playerNum = playerObj:getPlayerNum()
    local pos_x = getCore():getScreenWidth()/2 - MODAL_WIDTH/2
    local pos_y = getCore():getScreenHeight()/2 - MODAL_HEIGHT/2
    
	local modal = ISModalDialog:new(pos_x, pos_y, MODAL_WIDTH, MODAL_HEIGHT, getText("Tooltip_Suicide_Confirm"),
		                            true, nil, GunSuicide.suicideGun, playerNum, playerObj, gun)
	modal:initialise()
	modal.prevFocus = getPlayerMechanicsUI(playerNum)
	modal.moveWithMouse = true
	modal:addToUIManager()
	if JoypadState.players[playerNum+1] then
		setJoypadFocus(playerNum, modal)
	end
end


GunSuicide.onFillInventoryObjectContextMenu = function(player, context, items)
    local playerObj = getSpecificPlayer(player)

    local items = ISInventoryPane.getActualItems(items)
    local gun = nil
    local is_loaded_gun = false

    for _, item in ipairs(items) do
        if instanceof(item, "HandWeapon") and item:isAimedFirearm() then
            is_loaded_gun = (item:haveChamber() and item:isRoundChambered()) or (not item:haveChamber() and item:getCurrentAmmoCount() > 0)
            gun = item
        end
	end
    
    if gun then
        local option = context:addOption(getText("ContextMenu_GUN_SUICIDE"), playerObj, GunSuicide.onGunSuicide, gun)
        if option and not is_loaded_gun then
            local toolTip = ISToolTip:new()
            toolTip:initialise()
            
            option.toolTip = toolTip
            option.notAvailable = true

            toolTip:setName(getText("ContextMenu_GUN_SUICIDE"))
            toolTip.description = getText("Tooltip_No_Ammo")
        end
    end
end


Events.OnFillInventoryObjectContextMenu.Add(GunSuicide.onFillInventoryObjectContextMenu)
