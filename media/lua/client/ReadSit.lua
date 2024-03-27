
local function getChairTypeModifier(square)
    local _objects = square:getObjects()
    for j=0, _objects:size()-1 do
        local obj = _objects:get(j)
        local sprite = obj:getSprite()
        if sprite and sprite:getProperties() and sprite:getProperties():Is("CustomName") then
            if RCA.CHAIR_NAMES[sprite:getProperties():Val("CustomName")] then
                local chair_type = obj:getProperties():Val("BedType") or "averageBed"
                if chair_type == "goodBed" then
                    return 0.15
                elseif chair_type == "averageBed" then
                    return 0.1
                else
                    return 0.05
                end
            end
        end
    end
    return 0
end

local OldIsValid = ISReadABook.isValid
function ISReadABook:isValid()
    return  OldIsValid(self) == true
        and (self.character:isTimedActionInstant()
         or  self.character:isSitOnGround() == self.isCharacterSitOnGround)
end


local OldStop = ISReadABook.stop
function ISReadABook:stop()
    local result = OldStop(self)

    if not self.character:isTimedActionInstant() then
        local isSitOnGround = self.character:isSitOnGround()
        if    isSitOnGround and isSitOnGround ~= self.isCharacterSitOnGround then
            ISTimedActionQueue.add(ISReadABook:new(self.character, self.item, self.initialTime))
        end
    end


    return result
end


local OldNew = ISReadABook.new
function ISReadABook:new(character, item, time)
    
    local instance = OldNew(self, character, item, time)
    local effective = SandboxVars.RefinedCharacterActions.ReadingOnSitEffective / 100
    if instance.character:getVariableBoolean('isSitOnChair') then
        effective = effective - getChairTypeModifier(instance.character:getCurrentSquare())
    end

    if not instance.character:isTimedActionInstant() then
        instance.isCharacterSitOnGround = character:isSitOnGround()
        if instance.isCharacterSitOnGround then
            instance.maxTime = math.floor(instance.maxTime * effective)
            -- print(instance.maxTime)
        end
    end

    return instance
end
