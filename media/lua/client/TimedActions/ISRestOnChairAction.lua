
require "TimedActions/ISBaseTimedAction"

ISRestOnChairAction = ISBaseTimedAction:derive("ISRestOnChairAction")

function ISRestOnChairAction:isValid()
	return self.character:getStats():getEndurance() < 1
end

function ISRestOnChairAction:update()
    if self.character then
		self.character:updateEnduranceWhileSitting()
    end
end

function ISRestOnChairAction:start()
	self.character:setVariable("ExerciseStarted", false)
	self.character:setVariable("ExerciseEnded", true)
    self:setActionAnim("SitOnChair")
end

function ISRestOnChairAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISRestOnChairAction:perform()
	ISBaseTimedAction.perform(self)
end

function ISRestOnChairAction:new(character)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.stopOnWalk = true
	o.stopOnRun = true
    o.mul = 2
    o.maxTime = (1 - character:getStats():getEndurance()) * 16000
    o.caloriesModifier = 0.5

	return o
end
