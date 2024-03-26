require "RCAConst"

RCA = RCA or {}

RCA.BODY_LOCATIONS_MAP = RCAConst.VANILLA_BODY_LOCATIONS_MAP

RCA.startswith = function(str, prefix)
    if type(str) == 'string' then
        return str:find(prefix, 1, true) == 1
    else
        return false
    end
end


RCA.getMoveableDisplayName = function(obj)
	if not obj then return nil end
	if not obj:getSprite() then return nil end
	local props = obj:getSprite():getProperties()
	if props:Is("CustomName") then
		local name = props:Val("CustomName")
		if props:Is("GroupName") then
			name = props:Val("GroupName") .. " " .. name
		end
		return Translator.getMoveableDisplayName(name)
	end
	return nil
end


RCA.getDistanceToSquare = function(fromSquare, toSquare)
    local x1 = fromSquare:getX()
    local x2 = toSquare:getX()
    local y1 = fromSquare:getY()
    local y2 = toSquare:getY()
    if fromSquare:getZ() == square:getZ() then
        return math.sqrt(math.pow((y2-y1), 2) + math.pow((x2-x1), 2))
    else
        return math.huge
    end
end


RCA.findSquaresRadius = function(currSquare, radius, predicateCall, param1, param2, param3, param4, param5, param6)
    local squares = {}
    local doneSquares = {}
    local minX = math.floor(currSquare:getX() - radius)
	local maxX = math.ceil(currSquare:getX() + radius)
	local minY = math.floor(currSquare:getY() - radius)
	local maxY = math.ceil(currSquare:getY() + radius)
	for y = minY, maxY do
		for x = minX, maxX do
			local square = getCell():getGridSquare(x, y, currSquare:getZ())
			if square and not doneSquares[square] then
                doneSquares[square] = true
                if type(predicateCall) == 'function' then
                    if predicateCall(square, param1, param2, param3, param4, param5, param6) then
                        table.insert(squares, square)
                    end
                else
                    table.insert(squares, square)
                end
			end
		end
	end
    return squares
end


RCA.findOneClosestSquareRadius = function(currSquare, radius, predicateCall, param1, param2, param3, param4, param5, param6)
    local squares = {}
    local doneCoordinates = {}
    local curr_radius = 0

    while curr_radius <= radius do
        local minX = math.floor(currSquare:getX() - curr_radius)
	    local maxX = math.ceil(currSquare:getX() + curr_radius)
	    local minY = math.floor(currSquare:getY() - curr_radius)
	    local maxY = math.ceil(currSquare:getY() + curr_radius)
        for y = minY, maxY do
            for x = minX, maxX do
                coordinate = x .. '-' .. y
                if not doneCoordinates[coordinate] then
                    doneCoordinates[coordinate] = true
                    local square = getCell():getGridSquare(x, y, currSquare:getZ())
                    if square then
                        if type(predicateCall) == 'function' then
                            if predicateCall(square, param1, param2, param3, param4, param5, param6) then
                                return square
                            end
                        else
                            return square
                        end
                    end
                end
            end
        end
        curr_radius = curr_radius + 1
    end

    return nil
end



RCA.findWorldObjectsNearby = function(currSquare, radius, predicateCall, param1, param2, param3, param4, param5, param6)
    local worldobjects = {}
    local doneCoordinates = {}
    local curr_radius = 0

    while curr_radius <= radius do
        local minX = math.floor(currSquare:getX() - curr_radius)
	    local maxX = math.ceil(currSquare:getX() + curr_radius)
	    local minY = math.floor(currSquare:getY() - curr_radius)
	    local maxY = math.ceil(currSquare:getY() + curr_radius)
        for y = minY, maxY do
            for x = minX, maxX do
                local _coordinate = x .. '-' .. y
                if not doneCoordinates[_coordinate] then
                    doneCoordinates[_coordinate] = true
                    local square = getCell():getGridSquare(x, y, currSquare:getZ())
                    if square then
                        local _objects = square:getObjects()
                        for j=0, _objects:size()-1 do
                            local obj = _objects:get(j)
                            if type(predicateCall) == 'function' then
                                if predicateCall(obj, square, param1, param2, param3, param4, param5, param6) then
                                    table.insert(worldobjects, obj)
                                end
                            else
                                table.insert(worldobjects, obj)
                            end
                        end
                    end
                end
            end
        end
        curr_radius = curr_radius + 1
    end

    return worldobjects
end


RCA.findOneWorldObjectNearby = function(currSquare, radius, predicateCall, param1, param2, param3, param4, param5, param6)
    local worldobjects = {}
    local doneCoordinates = {}
    local curr_radius = 0

    while curr_radius <= radius do
        local minX = math.floor(currSquare:getX() - curr_radius)
	    local maxX = math.ceil(currSquare:getX() + curr_radius)
	    local minY = math.floor(currSquare:getY() - curr_radius)
	    local maxY = math.ceil(currSquare:getY() + curr_radius)
        for y = minY, maxY do
            for x = minX, maxX do
                local _coordinate = x .. '-' .. y
                if not doneCoordinates[_coordinate] then
                    doneCoordinates[_coordinate] = true
                    local square = getCell():getGridSquare(x, y, currSquare:getZ())
                    if square then
                        local _objects = square:getObjects()
                        for j=0, _objects:size()-1 do
                            local obj = _objects:get(j)
                            if type(predicateCall) == 'function' then
                                if predicateCall(obj, square, param1, param2, param3, param4, param5, param6) then
                                    return obj
                                end
                            else
                                return obj
                            end
                        end
                    end
                end
            end
        end
        curr_radius = curr_radius + 1
    end

    return nil
end