require "RCAConst"

RCA = RCA or {}

RCA.BODY_LOCATIONS_MAP = RCAConst.VANILLA_BODY_LOCATIONS_MAP


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


RCA.findSquaresRadius = function(currSquare, radius, predicateCall, args)
    local squares = {}
    local doneSquares = {}
    local currSquare = playerObj:getCurrentSquare()
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
                    if predicateCall(square, args) then
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


RCA.findClosestSquareRadius = function(currSquare, radius, predicateCall, args)
    local squares = {}
    local doneCoordinates = {}
    local currSquare = playerObj:getCurrentSquare()
    local curr_radius = 1
    while curr_radius <= radius do
        curr_radius = curr_radius + 1
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
                    if square and not doneSquares[square] then
                        doneSquares[square] = true
                        if type(predicateCall) == 'function' then
                            if predicateCall(square, args) then
                                return square
                            end
                        else
                            return square
                        end
                    end
                end
            end
        end
    end

    return nil
end