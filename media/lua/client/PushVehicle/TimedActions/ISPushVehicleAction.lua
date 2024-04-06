require "TimedActions/ISBaseTimedAction"

ISPushVehicleAction = ISBaseTimedAction:derive("ISPushVehicleAction")

ISPushVehicleAction.forceVector = Vector3f.new()
ISPushVehicleAction.positionVector = Vector3f.new()

function ISPushVehicleAction:isValid() 
    return true
end


function ISPushVehicleAction:waitToStart()
    local facingX = self.vehicle:getX()
    local facingY = self.vehicle:getY()
    self.character:facePosition(facingX, facingY)
	return self.character:shouldBeTurning()  -- keep waiting shouldBeTurning() to be false.
end


function ISPushVehicleAction:perform()
    self.character:getXp():AddXP(Perks.Strength, 5)
    self.character:getXp():AddXP(Perks.Fitness, 5)

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self)
end


function ISPushVehicleAction:update()
    -- cal force base on job delta.
    local forceDelta = self.force * (self:getJobDelta() - self.lastJobDelta)
    local forceVec, pushPoint = self:calPushForce(forceDelta)

    -- Shove the car
    self.vehicle:setPhysicsActive(true)
    self.vehicle:addImpulse(forceVec, pushPoint)

    -- update job delta
    self.lastJobDelta = self:getJobDelta()

end


function ISPushVehicleAction:start()
    
    self:setActionAnim("PushAction")

    self.lastJobDelta = 0

    -- Fatigue player
    local enduranceFactor = self.character:getPerkLevel(Perks.Fitness)
    enduranceFactor = math.min(1, enduranceFactor) * 2
    
    -- When push axis aligned, less effort
    if self.pushDir == 'Front' or 'Rear' then
        enduranceFactor = enduranceFactor * 4
    end

    -- Reduce Endurance/Increase Fatigue
    local enduranceHit = self.character:getStats():getEndurance() - (1 / enduranceFactor)
    self.character:getStats():setEndurance(enduranceHit)
    -- This part actually burns calories (AFAICT??)
    self.character:setMetabolicTarget(Metabolics.MediumWork)

end


function ISPushVehicleAction:stop()
    ISBaseTimedAction:stop(self)
end


function ISPushVehicleAction:new(character, vehicle, pushDirection)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.stopOnWalk, o.stopOnRun = true, true    
    o.maxTime = 50
    o.character = character
    o.vehicle = vehicle
    o.direction = pushDirection

    o.strength_level = o.character:getPerkLevel(Perks.Strength)
    o.force = 0.25 * o.strength_level  -- DO NOT change this number, unless know what doing.
    
    -- When push axis aligned, more effective.
    if o.direction == 'Front' or o.direction == 'Rear' then
        o.force = o.force * 1.2 + o.force * (10 - o.strength_level) /10
        -- DO NOT change those number, unless know what doing.
    end
    
    return o
end


function ISPushVehicleAction:calPushForce(forceDelta)
    local halfLen = self.vehicle:getScript():getPhysicsChassisShape():z() / 2
    local x = 0 
    local z = 0
    local fX = 0 
    local fZ = 0
    local forceCoeff = 0

    local pushAction = {
        -- DO NOT change those number, unless know what doing.
        ['Front'] = function() 
            fZ = -1 forceCoeff = 160 end,
        ['Rear'] = function()
            fZ = 1 forceCoeff = 160 end,

        ['LeftFront'] = function()
            fX = -1 z = halfLen forceCoeff = 45 end,
        ['LeftRear'] = function()
            fX = -1 z = -halfLen forceCoeff = 45 end,

        ['RightFront'] = function()
            fX = 1 z = halfLen forceCoeff = 45 end,
        ['RightRear'] = function()
            fX = 1 z = -halfLen forceCoeff = 45 end,
    }

    pushAction[self.direction]()

    -- Calculate the force vectors on the client
    local forcePos = self.vehicle:getWorldPos(fX, 0 , fZ, self.forceVector)
    local forceVec = forcePos:add(-self.vehicle:getX(), -self.vehicle:getY(), -self.vehicle:getZ())

    local pushPos = self.vehicle:getWorldPos(x, 0, z, self.positionVector)
    local pushPoint = pushPos:add(-self.vehicle:getX(), -self.vehicle:getY(), -self.vehicle:getZ())
    pushPoint:set(pushPoint:x(), 0, pushPoint:y())
 
    forceVec:mul(forceCoeff * forceDelta * self.vehicle:getMass())
    forceVec:set(forceVec:x(), 0, forceVec:y())

    return forceVec, pushPoint
end