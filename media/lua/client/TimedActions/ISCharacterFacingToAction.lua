require "TimedActions/ISBaseTimedAction"


ISCharacterFacingToAction = ISBaseTimedAction:derive("ISCharacterFacingToAction")


function ISCharacterFacingToAction:isValid()
	return true
end

function ISCharacterFacingToAction:stop()
	ISBaseTimedAction.stop(self)
end

function ISCharacterFacingToAction:perform()
	self.character:faceLocation(self.facingX, self.facingY)
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISCharacterFacingToAction:create()
	ISBaseTimedAction.create(self)
	self.action:setUseProgressBar(false)
end

function ISCharacterFacingToAction:new(character, to_x, to_y)
	if type(character) == 'number' then
		character = getSpecificPlayer(character)
		-- getSpecificPlayer param as int (player num).
	end
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.maxTime = 0
	o.stopOnWalk = true
	o.stopOnRun = true
	o.character = character
	o.playerNum = character:getPlayerNum()
	o.facingX = to_x
	o.facingY = to_y
	return o
end
