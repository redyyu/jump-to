
local TreadmillMenu = {}

TreadmillMenu.onPreFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    local treadmillMachine = nil
    local treadmillExercise = FitnessExercises.exercisesType.treadmill
    
    if not treadmillExercise then return end

    for _, obj in ipairs(worldobjects) do
        if obj:getSprite() and treadmillExercise.nearby.sprites[obj:getSprite():getName()] then
            treadmillMachine = obj
            break
        end

    end

    if treadmillMachine then 
        local treadmillRegularity = math.floor(playerObj:getFitness():getRegularity("treadmill"))
        local contextMenuText = getText("ContextMenu_USE_EXER_TREADMILL", treadmillRegularity)

        context:addDebugOption(contextMenuText,
                               worldobjects,
                               TreadmillMenu.onUseTreadmill,
                               playerObj,
                               treadmillMachine,
                               treadmillExercise,
                               60)
    end
    
    
end


-- Do when player selects option to use a treadmill (from context menu)
TreadmillMenu.onUseTreadmill = function(worldobjects, playerObj, treadmillMachine, treadmillExercise, length)
    
    forceDropHeavyItems(playerObj)

    playerObj:setPrimaryHandItem(nil)
    playerObj:setSecondaryHandItem(nil)
    
    if playerObj:getMoodles():getMoodleLevel(MoodleType.Endurance) > 2 then
        playerObj:Say(getText("IGUI_PlayerText_Too_Exhausted"))
        return
    end
    if playerObj:getMoodles():getMoodleLevel(MoodleType.Pain) > 3 then
        playerObj:Say(getText("IGUI_PlayerText_Too_Pain"))
        return
    end
            
    -- take off worn container items / bages
    for i=0, playerObj:getWornItems():size()-1 do
        local item = playerObj:getWornItems():get(i):getItem()
        if item and instanceof(item, "InventoryContainer") then
            ISTimedActionQueue.add(ISUnequipAction:new(playerObj, item, 50))
        end
    end
    
    if playerObj:getMoodles():getMoodleLevel(MoodleType.HeavyLoad) > 2 then
        playerObj:Say(getText("IGUI_PlayerText_Too_Heavy"))
        return
    end
    

    local facingX = treadmillMachine:getX()
    local facingY = treadmillMachine:getY()

    local properties = treadmillMachine:getSprite():getProperties()
    if properties:Is("Facing") then
        local facing = properties:Val("Facing")
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
    end

    if AdjacentFreeTileFinder.privTrySquare(playerObj:getCurrentSquare(), treadmillMachine:getSquare()) then
        ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, treadmillMachine:getSquare()))
        treadmillExercise.facingX = facingX
        treadmillExercise.facingY = facingY
        ISTimedActionQueue.add(ISFitnessAction:new(playerObj, treadmillExercise.type, length , ISFitnessUI:new(0,0, 600, 350, playerObj) , treadmillExercise))
    else
        
    end
end

if isDebugEnabled() then
    Events.OnPreFillWorldObjectContextMenu.Add(TreadmillMenu.onPreFillWorldObjectContextMenu)
end
