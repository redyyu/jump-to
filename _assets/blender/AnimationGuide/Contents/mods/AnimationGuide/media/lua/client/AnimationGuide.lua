--/////////////////////////////////////////////////////////////////////////
--//////////////////////////// Matías N. Salas ////////////////////////////
--///////////////////////////////////////////////////////////////////////// 
---@version 5.1 Kahlua

local onKeyStartPressed = function(key)
	local source = getPlayer(); if not source then return end

	if key == Keyboard.KEY_NUMPAD1 then
        source:setVariable("IsAnimationGuide", "true")
	end

    if key == Keyboard.KEY_NUMPAD2 then
        source:setVariable("IsAnimationGuide", "false")
    end

end

Events.OnKeyStartPressed.Add(onKeyStartPressed);