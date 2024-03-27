
local function getChairTypeModifier(char)
    local chair_type = char:getModData()['SitChairType']
    if chair_type == "goodBed" then
        return 0.15
    elseif chair_type == "averageBed" then
        return 0.1
    elseif chair_type == "badBed" then
        return 0.05
    else
        return 0
    end
end

local OldIsValid = ISReadABook.isValid
function ISReadABook:isValid()
    local current_valid = self.character:isTimedActionInstant() or self.character:isSitOnGround() == self.isCharacterSitOnGround
    return  OldIsValid(self) == true and current_valid
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
        effective = effective - getChairTypeModifier(instance.character)
    end

    if not instance.character:isTimedActionInstant() then
        instance.isCharacterSitOnGround = character:isSitOnGround()
        if instance.isCharacterSitOnGround then
            instance.maxTime = math.floor(instance.maxTime * effective)
        end
    end

    return instance
end
