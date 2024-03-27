--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISRestOnChairAction = ISBaseTimedAction:derive("ISRestOnChairAction")

function ISRestOnChairAction:isValid()
    return self.character:getStats():getEndurance() < 1
end

function ISRestOnChairAction:update()
    if self.character then
        self.character:updateEnduranceWhileSitting()
        -- DONT DO this, Unfair to Real Bad.
        -- for i=0, self.extraEnduranceLevel do
        --     self.character:updateEnduranceWhileSitting()
        -- end
    end
end

function ISRestOnChairAction:start()
    self.character:setVariable("ExerciseStarted", false)
    self.character:setVariable("ExerciseEnded", true)
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
    o.stopOnWalk = true
    o.stopOnRun = true
    o.forceProgressBar = true
    o.mul = 2
    o.maxTime = (1 - character:getStats():getEndurance()) * 16000
    o.caloriesModifier = 0.5
    
    o.chair = chair -- unused

    -- DONT DO this, Unfair to Real Bad.
    -- local bedType = chair:getProperties():Val("BedType") or "averageBed"
    -- if bedType == "goodBed" then
    --     o.extraEnduranceLevel = 3
    -- elseif bedType == "averageBed" then
    --     o.extraEnduranceLevel = 2
    -- elseif bedType == "badBed" then
    --     o.extraEnduranceLevel = 1
    -- else
    --     o.extraEnduranceLevel = 0
    -- end

    return o
end
