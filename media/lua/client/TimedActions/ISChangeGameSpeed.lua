require "TimedActions/ISBaseTimedAction"


ISChangeGameSpeed = ISBaseTimedAction:derive("ISChangeGameSpeed")


function ISChangeGameSpeed:isValid()
	return true
end

function ISChangeGameSpeed:stop()
	ISBaseTimedAction.stop(self)
end

function ISChangeGameSpeed:perform()
	UIManager.getSpeedControls():SetCurrentGameSpeed(self.gameSpeed)
	-- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end

function ISChangeGameSpeed:create()
	ISBaseTimedAction.create(self)
	self.action:setUseProgressBar(false)
end

function ISChangeGameSpeed:new(character, game_speed)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.maxTime = 0
	o.character = character
	o.stopOnWalk = false
	o.stopOnRun = false
	if game_speed == nil or game_speed == true then
		o.gameSpeed = 1
	elseif type(game_speed) ~= 'number' then
		o.gameSpeed = 0
	else
		game_speed = math.floor(game_speed)
		o.gameSpeed = math.max(math.min(game_speed, 3), 0)
	end
	return o
end
