require "TimedActions/ISBaseTimedAction"


ISSwimOutAction = ISBaseTimedAction:derive("ISSwimOutAction")


function ISSwimOutAction:isValid()
    return true
end


function ISSwimOutAction:start()
    self:setActionAnim("SwimOutWater")
    self.character:getEmitter():playSound("GetWaterFromLake")
    -- getEmitter() play as Ambient sound (zombie can hear).
    self.character:setIgnoreMovement(true)
end


function ISSwimOutAction:stop()
    self:restoreMovements()
    ISBaseTimedAction.stop(self) 
end


function ISSwimOutAction:perform()
    if self.performCall then
        self.performCall(self.character)
    end
    self:restoreMovements()
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self) 
end


function ISSwimOutAction:new(character, performCall)
    if type(character) == 'number' then
        character = getSpecificPlayer(character)
        -- getSpecificPlayer param as int (player num).
    end

    local o = {}
	setmetatable(o, self)
	self.__index = self
    o.stopOnAim = false 
    o.stopOnWalk = false 
    o.stopOnRun = false
    o.character = character
    o.performCall = performCall
    o.useProgressBar = false
    o.maxTime = 50
    return o
end


function ISSwimOutAction:restoreMovements()
    self.character:setIgnoreMovement(false)
end