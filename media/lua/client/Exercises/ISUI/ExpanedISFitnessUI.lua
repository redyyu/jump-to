require "ISUI/ISFitnessUI"


local function isExerciseDeviceNearby(obj, square, currentSquare, nearbySprites)
    if obj:getSprite() and nearbySprites[obj:getSprite():getName()] then
        -- DO NOT AdjacentFreeTileFinder.privTrySquare(currentSquare, square)
        -- might cause stackoverflow while large radius.
        return true
    end
    -- No need check prop name any more, but keep it comm here.
    -- local properties = obj:getSprite():getProperties()
    -- if not properties then 
    --     return false
    -- end
    -- if properties:Is("GroupName") and properties:Is("CustomName") then
    --     local fullName = properties:Val("GroupName")..' '..properties:Val("CustomName")
    --     if fullName == nearbyName then                
    --         return true
    --     end
    -- end
    return false
end


local function getDeviceFacing(device)
    if device:getSprite() then
        local properties = device:getSprite():getProperties()
        if properties:Is("Facing") then
            return properties:Val("Facing")
        end
    end
    return ''
end


local oldAddExerciseToList = ISFitnessUI.addExerciseToList

function ISFitnessUI:addExerciseToList(exerType, data)
    local text = data.name;
    local enabled = true;

    if data.nearby and not RCA.findOneWorldObjectNearby(self.player:getCurrentSquare(), 3, isExerciseDeviceNearby, data.nearby.sprites) then
        enabled = false
        text = text .. getText("IGUI_FitnessNeedNerbyDevice")
    elseif data.electricity and not RC.isSquarePowered(square) then
        enabled = false
        text = text .. getText("IGUI_FitnessNeedElectricity")
    end
    
    if enabled then
        oldAddExerciseToList(self, exerType, data)
    else
        self.exercises:addOption(text, exerType, nil, enabled)
    end
end


local oldUpdateButtons = ISFitnessUI.updateButtons
function ISFitnessUI:updateButtons(currentAction)
    oldUpdateButtons(self, currentAction)
    if self.exeData.nearby and not findDeviceNearby(self.player, self.exeData.nearby.sprites) then
        self.ok.enable = false
        self.ok.tooltip = self.exeData.name..getText("IGUI_FitnessNeedNerbyDevice")
    end
    
    if self.exeData.electricity and not RC.isSquarePowered(self.player:getCurrentSquare()) then
        self.ok.enable = false
        self.ok.tooltip = self.exeData.name..getText("IGUI_FitnessNeedElectricity")
    end
end


local oldOnClick = ISFitnessUI.onClick
function ISFitnessUI:onClick(button)
    if button.internal == "OK" then
        if self.exeData.nearby then
            local device = findDeviceNearby(self.player, self.exeData.nearby.sprites)
            if device then
                local facing = getDeviceFacing(device)
                local facingX = device:getSquare():getX()
                local facingY = device:getSquare():getY()

                -- DO NOT use getW, getE, getN, getS, ...
                -- seems get blocked square as nil.

                if facing == "S" then
                    facingY = facingY - 10
                    -- face_to_square = target_square:getN()
                elseif facing == "E" then
                    facingX = facingX - 10
                    -- face_to_square = target_square:getW()
                elseif facing == "W" then
                    facingX = facingX + 10
                    -- face_to_square = target_square:getE()
                elseif facing == "N" then
                    facingY = facingY + 10
                    -- face_to_square = target_square:getS()
                end

                ISTimedActionQueue.add(ISWalkToTimedAction:new(self.player, device:getSquare()))
                self.exeData.facingX = facingX
                self.exeData.facingY = facingY
            else
                self.player:Say(self.exeData.name..getText("IGUI_FitnessNeedNerbyDevice"))
            end
        end
        
        if self.exeData.electricity and not RC.isSquarePowered(self.player:getCurrentSquare()) then
            self.player:Say(self.exeData.name..getText("IGUI_FitnessNeedElectricity"))
            return
        end

    elseif button.internal == "CLOSE" then
        self.player:setVariable("ExerciseStarted", false);
        self.player:setVariable("ExerciseEnded", true);
    end
        
    oldOnClick(self, button)
end

