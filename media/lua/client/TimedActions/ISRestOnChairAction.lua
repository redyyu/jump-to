
require "TimedActions/ISBaseTimedAction"

ISRestOnChairAction = ISBaseTimedAction:derive("ISRestOnChairAction")

function ISRestOnChairAction:isValid()
    return self.sitSquare ~= nil and 
           self.chair:getSprite() ~= nil and 
           self.chair:getSprite():getProperties() ~= nil
end

function ISRestOnChairAction:waitToStart()
    local facingX = self.sitSquare:getX() 
    local facingY = self.sitSquare:getY()
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

function ISRestOnChairAction:update()
    if self.character and self.character:getStats():getEndurance() < 1 then
        self.character:updateEnduranceWhileSitting()
    end
end

function ISRestOnChairAction:start()
    self.character:setVariable("ExerciseStarted", false)
    self.character:setVariable("ExerciseEnded", true)
    self.character:setIgnoreAimingInput(true)

    if self.sitSquare == self.chair:getSquare() then
        self:setActionAnim("SitOnChair")
    elseif self.sitSquare == self.character:getCurrentSquare() then
        self:setActionAnim("SitOnChairOffset")
    end
end

function ISRestOnChairAction:stop()
    self:restoreMovements()
    ISBaseTimedAction.stop(self)
end

function ISRestOnChairAction:perform()
    self:restoreMovements()
    ISBaseTimedAction.perform(self)
end

function ISRestOnChairAction:new(character, chair, sitSquare)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    
    o.stopOnWalk = true
    o.stopOnRun = true
    o.character = character
    o.chair = chair
    o.sitSquare = sitSquare

    if character:getStats():getEndurance() < 1 then
        o.maxTime = (1 - character:getStats():getEndurance()) * 16000
    else
        o.useProgressBar = false
        o.maxTime = -1
    end
    o.caloriesModifier = 0.5

    return o
end


function ISRestOnChairAction:restoreMovements()
    self.character:setIgnoreAimingInput(false)
    UIManager.getSpeedControls():SetCurrentGameSpeed(1)
end