
require "TimedActions/ISBaseTimedAction"

ISSitOnChairAction = ISBaseTimedAction:derive("ISSitOnChairAction")

function ISSitOnChairAction:isValid()
    return not self.character:getVehicle()
end

function ISSitOnChairAction:waitToStart()
    local facingX = self.sitSquare:getX() 
    local facingY = self.sitSquare:getY()
    if not self.chair:getSprite() or not self.chair:getSprite():getProperties() then
        return false
    end
    local props = self.chair:getSprite():getProperties()
    local facing = props:Val("Facing")
    if facing == "S" then
        facingY = facingY + 10
    elseif facing == "E" then
        facingX = facingX + 10
    elseif facing == "W" then
        facingX = facingX - 10
    elseif facing == "N" then
        facingY = facingY - 10
    end
    self.character:faceLocation(facingX, facingY)
    return self.character:shouldBeTurning()
end

function ISSitOnChairAction:stop()
    ISBaseTimedAction.stop(self)
end

function ISSitOnChairAction:perform()
    if self.sitSquare == self.chair:getSquare() then
        self.character:setVariable("SitChair", "normal")
    elseif self.sitSquare == self.character:getCurrentSquare() then
        self.character:setVariable("SitChair", "offset")
    end
    self.character:reportEvent("EventSitOnGround")
    ISBaseTimedAction.perform(self)
end

function ISSitOnChairAction:new(character, chair, sitSquare)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.stopOnWalk = true
    o.stopOnRun = true
    o.character = character
    o.chair = chair
    o.sitSquare = sitSquare
    o.useProgressBar = false
    o.maxTime = 0
    o.loopedAction = false
    o.ignoreHandsWounds = true
    
    return o
end
