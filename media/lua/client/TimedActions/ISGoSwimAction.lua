require "TimedActions/ISBaseTimedAction"


ISGoSwimAction = ISBaseTimedAction:derive("ISGoSwimAction")


function ISGoSwimAction:isValid()
    if self.waterSquare and not self.waterSquare:isFree(false) and self.character:getZ() == self.waterSquare:getZ() then
        local sprite = self.waterSquare:getFloor():getSprite()
        if sprite and sprite:getProperties() then
            return sprite:getProperties():Is(IsoFlagType.water)
        else
            return false
        end
    else
        return false
    end
end


function ISGoSwimAction:update()
    if self.item then
        self.item:setJobDelta(self:getJobDelta())
    end
end


function ISGoSwimAction:start()
    if self.item then
        self.item:setJobType(getText("ContextMenu_Unequip") .. " " .. self.item:getName()) 
        self.item:setJobDelta(0.0) 
        if self.fromHotbar then
            self.character:setVariable("AttachItemSpeed", self.animSpeed)
            self.hotbar:setAttachAnim(self.item) 
            self:setActionAnim("AttachItem")
            self:setOverrideHandModels(self.item, nil)
            self.character:reportEvent("EventAttachItem") 
        elseif self.item:IsClothing() then
            self:setActionAnim("WearClothing") 
            local location = self.item:getBodyLocation()
            self:setAnimVariable("WearClothingLocation", WearClothingAnimations[location] or "")
            self.character:reportEvent("EventWearClothing") 
        elseif self.item:IsInventoryContainer() and self.item:canBeEquipped() ~= "" then
            self:setActionAnim("WearClothing") 
            local location = self.item:canBeEquipped()
            self:setAnimVariable("WearClothingLocation", WearClothingAnimations[location] or "")
        else
            self:setActionAnim("UnequipItem") 
        end
        if self.item:getUnequipSound() then
            self.sound = self.character:getEmitter():playSound(self.item:getUnequipSound())
        end
    end
end

function ISGoSwimAction:stop()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
    end
    if self.item then
        self.item:setJobDelta(0.0)
    end
    ISBaseTimedAction.stop(self) 
end

function ISGoSwimAction:animEvent(event, parameter)
    if self.item and event == 'attachConnect' then
        local hotbar = getPlayerHotbar(self.character:getPlayerNum()) 
        hotbar.chr:setAttachedItem(self.item:getAttachedToModel(), self.item) 
        self:setOverrideHandModels(nil, nil)
        if self.maxTime == -1 then
            self:forceComplete()
        end
    end
end

function ISGoSwimAction:perform()
    if self.sound then
        self.character:getEmitter():stopSound(self.sound)
    end
    if self.item then
        self.item:getContainer():setDrawDirty(true) 
        self.item:setJobDelta(0.0) 
        self.character:removeWornItem(self.item)

        if self.fromHotbar then
            local hotbar = getPlayerHotbar(self.character:getPlayerNum()) 
            hotbar.chr:setAttachedItem(self.item:getAttachedToModel(), self.item) 
            self:setOverrideHandModels(nil, nil)
        end

        if self.item == self.character:getPrimaryHandItem() then
            if (self.item:isTwoHandWeapon() or self.item:isRequiresEquippedBothHands()) and self.item == self.character:getSecondaryHandItem() then
                self.character:setSecondaryHandItem(nil) 
            end
            self.character:setPrimaryHandItem(nil) 
        end
        if self.item == self.character:getSecondaryHandItem() then
            if (self.item:isTwoHandWeapon() or self.item:isRequiresEquippedBothHands()) and self.item == self.character:getPrimaryHandItem() then
                self.character:setPrimaryHandItem(nil) 
            end
            self.character:setSecondaryHandItem(nil) 
        end
        triggerEvent("OnClothingUpdated", self.character)
        if isForceDropHeavyItem(self.item) then
            self.character:getInventory():Remove(self.item) 
            local dropX,dropY,dropZ = ISInventoryTransferAction.GetDropItemOffset(self.character, self.character:getCurrentSquare(), self.item)
            self.character:getCurrentSquare():AddWorldInventoryItem(self.item, dropX, dropY, dropZ)
        end
        ISInventoryPage.renderDirty = true
    end

    self.character:setX(self.waterSquare:getX())
    self.character:setY(self.waterSquare:getY())

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self) 
end


function ISGoSwimAction:new(character, toSquare, time)
    if type(character) == 'number' then
        character = getSpecificPlayer(character)
        -- getSpecificPlayer param as int (player num).
    end
    
    local o = ISBaseTimedAction.new(self, character) 

    o.item = character:getWornItem('Shoes')
    o.stopOnAim = false 
    o.stopOnWalk = false 
    o.stopOnRun = true 
    o.maxTime = time 
    o.ignoreHandsWounds = true 

    
    if o.item then
        o.hotbar = getPlayerHotbar(character:getPlayerNum()) 
        if o.hotbar then
            o.fromHotbar = o.hotbar:isItemAttached(o.item) 
        else
            o.fromHotbar = false 
        end

        o.useProgressBar = not o.fromHotbar
    
        if o.character:isTimedActionInstant() then
            o.maxTime = 1 
        end
        if o.maxTime > 1 and o.fromHotbar then
            o.animSpeed = o.maxTime / o:adjustMaxTime(o.maxTime)
            o.maxTime = -1
        else
            o.animSpeed = 1.0
        end
    else
        o.maxTime = 0
        o.animSpeed = 0
        o.useProgressBar = false
    end

    o.waterSquare = toSquare

    return o
end
