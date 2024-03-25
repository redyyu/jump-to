require "TimedActions/ISBaseTimedAction"


ISSwimToAction = ISBaseTimedAction:derive("ISSwimToAction")


function ISSwimToAction:isValid()
    if self.toSquare and self.character:getZ() == self.toSquare:getZ() then
        if self.inWater then
            local sprite = self.toSquare:getFloor():getSprite()
            if sprite and sprite:getProperties() then
                return sprite:getProperties():Is(IsoFlagType.water)
            else
                return false
            end
        else
            return self.toSquare:isFree(false)
        end
    else
        return false
    end
end


function ISSwimToAction:start()
    if self.inWater then
        self:setActionAnim("SwimInWater")
    else
        self:setActionAnim("SwimOutWater")
    end
end

function ISSwimToAction:stop()
    ISBaseTimedAction.stop(self) 
end

function ISSwimToAction:animEvent(event, parameter)
    -- if event == 'some_event_from_animSets' then
    --     if self.maxTime == -1 then
    --         self:forceComplete()
    --     end
    -- end
end

function ISSwimToAction:perform()
    self.character:setX(self.toSquare:getX())
    self.character:setY(self.toSquare:getY())

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self) 
end


function ISSwimToAction:new(character, toSquare, inWater)
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
    o.inWater = inWater
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
