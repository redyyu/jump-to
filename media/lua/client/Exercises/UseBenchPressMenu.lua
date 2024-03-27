
local BenchPressMenu = {}

BenchPressMenu.onPreFillWorldObjectContextMenu = function(playerNum, context, worldobjects)
    local playerObj = getSpecificPlayer(playerNum)
    local benchMachine = nil
    local benchExercise = FitnessExercises.exercisesType.benchpress
    
    if not benchExercise then return end

    for _, obj in ipairs(worldobjects) do
        if obj:getSprite() and benchExercise.nearby.sprites[obj:getSprite():getName()] then
            benchMachine = obj
            break
        end
    end

    if benchMachine then
        local benchRegularity = math.floor(playerObj:getFitness():getRegularity("benchpress"))
        local contextMenuText = getText("ContextMenu_USE_EXER_BENCH", benchRegularity)

        context:addDebugOption(contextMenuText,
                               worldobjects,
                               BenchPressMenu.onUseBench,
                               playerObj,
                               benchMachine,
                               benchExercise,
                               60)
    end
    
end


BenchPressMenu.onUseBench = function (worldobjects, playerObj, benchMachine, benchExercise, length)

    forceDropHeavyItems(playerObj)
    
    if not playerObj:getInventory():contains("Base.BarBell", true) then
        playerObj:Say(getText("IGUI_PlayerText_Need_Barbell"))
        return
    end
    if playerObj:getMoodles():getMoodleLevel(MoodleType.Endurance) > 2 then
        playerObj:Say(getText("IGUI_PlayerText_Too_Exhausted"))
        return
    end
    if playerObj:getMoodles():getMoodleLevel(MoodleType.Pain) > 3 then
        playerObj:Say(getText("IGUI_PlayerText_Too_Pain"))
        return
    end
    
    -- take off and drop worn container items / bages
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
        
    ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), "Base.BarBell", true, true)

    local facingX = benchMachine:getX()
    local facingY = benchMachine:getY()

    local properties = benchMachine:getSprite():getProperties()
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
    if AdjacentFreeTileFinder.privTrySquare(playerObj:getCurrentSquare(), benchMachine:getSquare()) then
        ISTimedActionQueue.add(ISWalkToTimedAction:new(playerObj, benchMachine:getSquare()))
        benchExercise.facingX = facingX
        benchExercise.facingY = facingY
        ISTimedActionQueue.add(ISFitnessAction:new(playerObj, benchExercise.type, length , ISFitnessUI:new(0,0, 600, 350, playerObj) , benchExercise))
    end
end

if isDebugEnabled() then
    Events.OnPreFillWorldObjectContextMenu.Add(BenchPressMenu.onPreFillWorldObjectContextMenu)
end
