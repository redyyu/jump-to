
require "TimedActions/ISBaseTimedAction"

ISRestOnChairAction = ISBaseTimedAction:derive("ISRestOnChairAction")

function ISRestOnChairAction:isValid()
	return self.character:getStats():getEndurance() < 1 and 
		   self.chair:getSprite() ~= nil and 
		   self.chair:getSprite():getProperties() ~= nil
end

function ISRestOnChairAction:waitToStart()
	local facingX = self.character:getCurrentSquare():getX()  -- make sure X, Y not middle of square.
	local facingY = self.character:getCurrentSquare():getY()
	local props = self.chair:getSprite():getProperties()
	local facing = props:Val("Facing")
	if facing == "S" then
		facingY = facingY + 10
	elseif facing == "E" then
		facingX = facingX - 10
	elseif facing == "W" then
		facingX = facingX + 10
	elseif facing == "N" then
		facingY = facingY - 10
	end
    self.character:faceLocation(facingX, facingY)
	return self.character:shouldBeTurning()
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

function ISRestOnChairAction:new(character, chair)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
	o.chair = chair
	o.stopOnWalk = true
	o.stopOnRun = true
    o.mul = 2
    o.maxTime = (1 - character:getStats():getEndurance()) * 16000
    o.caloriesModifier = 0.5

	return o
end
