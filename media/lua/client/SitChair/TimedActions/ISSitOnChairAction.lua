
require "TimedActions/ISBaseTimedAction"

ISSitOnChairAction = ISBaseTimedAction:derive("ISSitOnChairAction")

function ISSitOnChairAction:isValid()
    return not self.character:getVehicle() and not self.character:getVariableBoolean('isSitOnChair')
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

-- put in start will play `sit` on chair earlier.
function ISSitOnChairAction:start()
    self:setChairVariable()
end


function ISSitOnChairAction:perform()
    -- self:setChairVariable()
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

    character:getModData()['SitChairType'] = chair:getProperties():Val("BedType") or "averageBed"
    
    return o
end


function ISSitOnChairAction:setChairVariable()
    if self.sitSquare == self.chair:getSquare() then
        self.character:setVariable("SitChair", "normal")
    elseif self.sitSquare == self.character:getCurrentSquare() then
        self.character:setVariable("SitChair", "offset")
    else
        self.character:setVariable("SitChair", "normal")
    end
    self.character:setVariable('isSitOnChair', true)
    self.character:reportEvent("EventSitOnGround")
end