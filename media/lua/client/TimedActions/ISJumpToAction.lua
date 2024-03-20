require "TimedActions/ISBaseTimedAction"

ISJumpToAction = ISBaseTimedAction:derive("ISJumpToAction")


function ISJumpToAction:isValid()
    return true
end


function ISJumpToAction:isValidStart()
    return true
end


function ISJumpToAction:animEvent(event, parameter)
    if event == 'JumpDone' then
        -- NO NEED restoreMovements() here. 
        -- the timedAction with maxTime, it will perform/stop anyway.
        -- right here is to prevent animtion is end before the action reach maxTime.
        -- otherwsie some other animtion will play.
        self.character:setRunning(self.hasRunning)
        self.character:setSprinting(self.hasSprinting)
        self.character:setSneaking(false)
    elseif event == 'TouchGround' then
        self.forceZ = nil
    elseif event == 'Thump' then
        -- pass
    end
end


function ISJumpToAction:update()
    if self.forceZ then
        -- The Empty Midair can be block movement,
        -- a floor beside empty space, will have 1 square neighbours is allow player move in to.
        -- it is empty space (player will falling in this square). 
        -- since this mod is limit player can only jump over 2 empty square.
        -- start square and dest square will both have 1 square empty space for play go in.
        -- So No need those than. (unless need to jump over more than 2 square)

        -- if currentSquare and currentSquare ~= self.lastKnownSquare then
        --     if not currentSquare:Is(IsoFlagType.solidfloor) then
        --         currentSquare:addFloor('')
        --         currentSquare:RecalcAllWithNeighbours(true)
        --     end
        --     self.lastKnownSquare = currentSquare
        -- end
        
        -- prevent falling while jumping.
        self.character:setFallTime(0)
        self.character:setbFalling(false)
        self.character:setZ(self.forceZ)

        -- that's all, NO NEED move player by self made coding.
        -- froced the player not falling, that mean can still moving 1 square on empty space.
        -- when player jumping, the square cross over must have 1 square empty space too.
        -- since limited can only jump over 2 square at top.
        -- player is actually move to cross over, just a jump animtion is playing, make it looks like jumping.
        -- even want jump to (actually is move to) more than 2 square, just addFloor will be fine.
        -- I don't how to restore those added floor, and 2 square if good enough. that's why not do that.
        -- so there is no reason to coding custom movements.
        -- also keep using vanilla Collision, no need custom blocked check.

        if not self.character:getSquare():isFree(false) then
            -- NO NEED care about the Collision. player already in a unfree square.
            -- this is for free the player.
            -- etc. player drop into a river or lake, and not enough materials to build floor. 
            -- that will unable to move any way.
            local deltaX = (self.destX - self.startX) * self:getJobDelta()
            local deltaY = (self.destY - self.startY) * self:getJobDelta()

            self.character:setX(self.startX + deltaX)
            self.character:setY(self.startY + deltaY)
            self.character:setZ(0)
        end
    end
end


function ISJumpToAction:start()
    if self.anim then
        self:consumeEndurance()  -- consumeEndurance anyway.
        self:setActionAnim(self.anim)
        self.startSquare = self.character:getCurrentSquare()
        self.startX = self.character:getX()
        self.startY = self.character:getY()
        self.forceZ = self.character:getZ()
        self.character:setIgnoreMovement(true)
        self.character:setRunning(false)
        self.character:setSprinting(false)
        self.character:setSneaking(false)
    end
end


function ISJumpToAction:create()
    if self.hasSprinting then
        self.anim = 'JumpSprintStart'
    elseif self.hasRunning then
        self.anim = 'JumpRunStart'
    else
        -- for select from menu while standing
        self.anim = 'JumpSprintStart'
    end
    ISBaseTimedAction.create(self)
end


function ISJumpToAction:stop()
    self:restoreMovements()
    ISBaseTimedAction.stop(self)
end


function ISJumpToAction:perform()
    self:restoreMovements()
    ISBaseTimedAction.perform(self)
end


function ISJumpToAction:new(character, destSquare, distance)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.stopOnWalk = false
    o.stopOnRun = false
    o.stopOnAim = false

    o.destX = destSquare:getX()
    o.destY = destSquare:getY()

    o.hasSprinting = character:isSprinting()
    o.hasRunning = character:isRunning()

    o.useProgressBar = false

    print('---------------distance--------------------')
    print(distance)

    o.maxTime = 10 * distance
    o.anim = nil
   
    return o
end


function ISJumpToAction:restoreMovements()
    self.character:setIgnoreMovement(false)
    self.character:setRunning(self.hasRunning)
    self.character:setSprinting(self.hasSprinting)
    self.character:setSneaking(false)
    self.forceZ = nil
end

function ISJumpToAction:consumeEndurance() --same as vault over fence
    local stats = self.character:getStats()
    if self.hasSprinting then
        stats:setEndurance(stats:getEndurance() - ZomboidGlobals.RunningEnduranceReduce * 700.0)
    elseif self.hasRunning then
        stats:setEndurance(stats:getEndurance() - ZomboidGlobals.RunningEnduranceReduce * 300.0)
    end
end
