-- NO NEED those code
-- but it is take alot time to get understand.
-- keep it here
-- Credit: Tchernobill

-- JmpUtils = {}

-- JmpUtils.isBlocked = function(square, toSquare)
--     if not square or not toSquare then
--         return false
--     end
--     if square:isBlockedTo(toSquare) or 
--        square:testCollideSpecialObjects(toSquare) or
--        toSquare:isSolidTrans() or 
--        toSquare:isSolid() then
--         return true
--     else
--         return false
--     end
-- end

-- JmpUtils.canTraverseToRecurse = function(fromSquare, targetSquare, ew, sn, 
--                                     ewBlocked, snBlocked, diagEwBlocked, diagSnBlocked, _count)
--     if _count then
--         if _count > 10 then
--             return
--         else
--             _count = _count + 1
--         end
--     else
--         _count = 1
--     end

--     -- works only for straight UP/DOWN/RIGHT/LEFT screen directions (no Z, no diagonal). 
--     -- they need a real algorithm instead of that unsafe sh*t.
    
--     local ew_square = fromSquare:getAdjacentSquare(ew)
--     if not ewBlocked then
--         ewBlocked = JmpUtils.isBlocked(fromSquare, ew_square)
--     end
--     if targetSquare == ew_square then
--         return not (ewBlocked or diagEwBlocked)
--     end

--     local sn_square = fromSquare:getAdjacentSquare(sn)
--     if not snBlocked then
--         snBlocked = JmpUtils.isBlocked(fromSquare, sn_square)
--     end
--     if targetSquare == sn_square then
--         return not (snBlocked or diagSnBlocked)
--     end

--     local diagonal_square = nil
--     if ew_square then
--         diagonal_square = ew_square:getAdjacentSquare(sn)
--         -- same as sn_square:getAdjacentSquare(ew)
--     elseif sn_square then
--         diagonal_square = sn_square:getAdjacentSquare(ew)
--         -- same as ew_square:getAdjacentSquare(sn)
--     end
    
--     if not diagonal_square then
--         printDebug('missing diag square.', 'canTraverseToRecurse')
--         return false
--     end

--     if not diagSnBlocked then
--         diagSnBlocked = JmpUtils.isBlocked(sn_square, diagonal_square)
--     end

--     if not diagEwBlocked then
--         diagEwBlocked = JmpUtils.isBlocked(ew_square, diagonal_square)
--     end

--     if diagonal_square == targetSquare then 
--         return (snBlocked or ewBlocked or diagEwBlocked or diagSnBlocked)
--     end
--     return JmpUtils.canTraverseToRecurse(diagonal_square, targetSquare, ew, sn, 
--                                     ewBlocked, snBlocked, diagEwBlocked, diagSnBlocked,
--                                     _count)

-- end


-- JmpUtils.canTraverseTo = function(character, deltaX, deltaY, deltaZ)
--     if not deltaX then deltaX = 0 end
--     if not deltaY then deltaY = 0 end
--     if not deltaZ then deltaZ = 0 end

--     local targetX = character:getX() + deltaX
--     local targetY = character:getY() + deltaY
--     local targetZ = character:getZ() + deltaZ

--     --check destination is not inside a vehicle
--     if targetZ < 1 then
--         local vehicle = character:getNearVehicle()
--         if vehicle then --if there is a vehicle around
--             if vehicle:isInBounds(targetX, targetY) then
--                 return false
--             end
--         end
--     end
    
--     --check destination is valid
--     if not getWorld():isValidSquare(targetX, targetY, targetZ) then
--         return false
--     end

--     --check destination is reachable
--     local currentSquare = character:getCurrentSquare()
--     if not currentSquare then
--         printDebug("canMoveTo: invalid player square. WARNING", "JumpToMenu")
--         return false
--     end

--     local destSquare = getCell():getGridSquare(targetX, targetY, targetZ)
--     if currentSquare == destSquare then
--         return true
--     end
    
--     if JmpUtils.isBlocked(currentSquare, destSquare) then
--         return false
--     end

--     local ewBlocked = false
--     local snBlocked = false
--     local diagEwBlocked = false
--     local diagSnBlocked = false

--     local ew = nil
--     if deltaX > 0 then --Horizontal direction of movement
--         ew = IsoDirections.E
--     else
--         ew = IsoDirections.W
--     end

--     local sn = nil
--     if deltaY > 0 then --Vertical direction of movement
--         sn = IsoDirections.S
--     else
--         sn = IsoDirections.N
--     end

--     return JmpUtils.canTraverseToRecurse(currentSquare, destSquare, ew, sn, ewBlocked, snBlocked, diagEwBlocked, diagSnBlocked)
-- end
