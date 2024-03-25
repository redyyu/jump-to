--***********************************************************
--**                    ROBERT JOHNSON                     **
--***********************************************************

require "TimedActions/ISBaseTimedAction"

ISSwimTakeWaterAction = ISBaseTimedAction:derive("ISSwimTakeWaterAction")

function ISSwimTakeWaterAction:isValid()
	-- If the player is very thirsty, the destination item may get drained while filling it.
	-- When drained, the item may turn into another "empty" item, removing the item we're filling
	-- from it's container.
	return self.waterObject:hasWater()
end


function ISSwimTakeWaterAction:start()
    local waterAvailable = self.waterObject:getWaterAmount()
    local props = self.waterObject:getProperties()
    local hasWaterFlag = (props ~= nil) and props:Is(IsoFlagType.water)
    local isLakeOrRiver = not instanceof(self.waterObject, "IsoWorldInventoryObject") and (props ~= nil) and luautils.stringStarts(self.waterObject:getSprite():getName(), 'blends_natural_02')
    local isPuddle = not hasWaterFlag and not isLakeOrRiver and (props ~= nil) and props:Is(IsoFlagType.solidfloor)
    
    if isLakeOrRiver or isPuddle then
        self.sound = self.character:playSound("DrinkingFromRiver")
    elseif instanceof(self.waterObject, "IsoThumpable") or hasWaterFlag or isLakeOrRiver then -- play the drink sound for rain barrel
        self.sound = self.character:playSound("DrinkingFromPool")
        -- getSoundManager():PlayWorldSoundWav("PZ_DrinkingFromBottle", self.character:getCurrentSquare(), 0, 2, 0.8, true)
    else
        self.sound = self.character:playSound("DrinkingFromTap")
        -- getSoundManager():PlayWorldSound("PZ_DrinkingFromTap", self.character:getCurrentSquare(), 0, 2, 0.8, true)
    end
    local thirst = self.character:getStats():getThirst()
    local waterNeeded = math.min(math.ceil(thirst / 0.1), 10)
    self.waterUnit = math.min(waterNeeded, waterAvailable)
    self.action:setTime((self.waterUnit * 10) + 15)

    -- those will break swimming animations.
    -- self:setOverrideHandModels(nil, nil)
    -- self:setActionAnim("drink_tap")

	self.character:reportEvent("EventTakeWater")
end

function ISSwimTakeWaterAction.SendTakeWaterCommand(playerObj, object, units)
    if instanceof(object, "IsoWorldInventoryObject") then
        local itemID = object:getItem():getID()
        local args = {x=object:getX(), y=object:getY(), z=object:getZ(), units=units, itemID=itemID}
        sendClientCommand(playerObj, 'object', 'takeWaterFromItem', args)
        return
    end
    local index = object:getObjectIndex()
    local args = {x=object:getX(), y=object:getY(), z=object:getZ(), units=units, index=index}
    sendClientCommand(playerObj, 'object', 'takeWater', args)
end

function ISSwimTakeWaterAction:stopSound()
	if self.sound and self.character:getEmitter():isPlaying(self.sound) then
		self.character:stopOrTriggerSound(self.sound)
	end
end

function ISSwimTakeWaterAction:stop()
	self:stopSound()
    local used = self:getJobDelta() * self.waterUnit
    if used >= 1 then
        ISSwimTakeWaterAction.SendTakeWaterCommand(self.character, self.waterObject, used)
    end
    ISBaseTimedAction.stop(self)
end

function ISSwimTakeWaterAction:perform()
	self:stopSound()
    
    local thirst = self.character:getStats():getThirst() - (self.waterUnit / 10)
    self.character:getStats():setThirst(math.max(thirst, 0.0))
    if self.waterObject:isTaintedWater() then
        --tainted water shouldn't kill the player but make them sick - dangerous when sick
        local bodyDamage	= self.character:getBodyDamage()
        local stats			= self.character:getStats()
        if bodyDamage:getPoisonLevel() < 20 and stats:getSickness() < 0.3 then
            bodyDamage:setPoisonLevel(math.min(bodyDamage:getPoisonLevel() + 10 + self.waterUnit, 20))
        end
    end

    ISSwimTakeWaterAction.SendTakeWaterCommand(self.character, self.waterObject, self.waterUnit)

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)
end

function ISSwimTakeWaterAction:new(character, waterUnit, waterObject, time)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o.character = character
    o.stopOnAim = true 
	o.stopOnWalk = true
	o.stopOnRun = true
	o.maxTime = 10 -- will set this in start()
	o.waterUnit = waterUnit -- will set this in start()
	o.waterObject = waterObject
	return o
end
