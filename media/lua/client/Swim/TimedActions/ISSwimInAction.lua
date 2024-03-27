require "TimedActions/ISBaseTimedAction"


ISSwimInAction = ISBaseTimedAction:derive("ISSwimInAction")


function ISSwimInAction:isValid()
    if self.toSquare and self.character:getZ() == self.toSquare:getZ() then
        local sprite = self.toSquare:getFloor():getSprite()
        if sprite and sprite:getProperties() then
            return sprite:getProperties():Is(IsoFlagType.water)
        else
            return false
        end
    else
        return false
    end
end

function ISSwimInAction:waitToStart()
    self.character:faceLocation(self.toSquare:getX(), self.toSquare:getY())
	return self.character:shouldBeTurning()  -- keep waiting shouldBeTurning() to be false.
end


function ISSwimInAction:start()
    self:setActionAnim("SwimInWater")
    self.character:setIgnoreMovement(true)
end


function ISSwimInAction:stop()
    self:restoreMovements()
    ISBaseTimedAction.stop(self) 
end

function ISSwimInAction:animEvent(event, parameter)
    -- if event == 'some_event_from_animSets' then
    --     if self.maxTime == -1 then
    --         self:forceComplete()
    --     end
    -- end
end

function ISSwimInAction:perform()
    self.character:setX(self.toSquare:getX())
    self.character:setY(self.toSquare:getY())
    self.character:getEmitter():playSound("GetWaterFromLake")
    -- getEmitter() play as Ambient sound (zombie can hear).
    self:restoreMovements()
    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self) 
end


function ISSwimInAction:new(character, toSquare)
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
    o.toSquare = toSquare
    o.useProgressBar = false
    o.maxTime = 25

    -- if o.character:isTimedActionInstant() then
    --     o.maxTime = 1 
    -- end
    -- if o.maxTime > 1 and o.fromHotbar then
    --     o.animSpeed = o.maxTime / o:adjustMaxTime(o.maxTime)
    --     o.maxTime = -1
    -- else
    --     o.animSpeed = 1.0
    -- end

    return o
end


function ISSwimInAction:restoreMovements()
    self.character:setIgnoreMovement(false)
end