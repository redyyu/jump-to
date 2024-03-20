require "BuildingObjects/ISBuildingObject"

ISJumpToCursor = ISBuildingObject:derive("ISJumpToCursor")


function ISJumpToCursor:create(x, y, z, north, sprite)
	local square = getWorld():getCell():getGridSquare(x, y, z)
	local duration = self.durationCall(self.character)
	if duration > 0 then
		ISTimedActionQueue.clear(self.character)
		ISTimedActionQueue.add(ISJumpToAction:new(self.character, square, duration))
	end
end

function ISJumpToCursor:isValid(square)
	local in_range_x = math.abs(square:getX() - self.character:getX()) <= 5
	local in_range_y = math.abs(square:getY() - self.character:getY()) <= 5
	-- no matter distance, the square only use to give direction to jump.
	-- give 5 square range for better uex.
	return in_range_x and in_range_y
end

function ISJumpToCursor:render(x, y, z, square)
	if not ISJumpToCursor.floorSprite then
		ISJumpToCursor.floorSprite = IsoSprite.new()
		ISJumpToCursor.floorSprite:LoadFramesNoDirPageSimple('media/ui/FloorTileCursor.png')
	end

	local hc = getCore():getGoodHighlitedColor()
	if not self:isValid(square) then
		hc = getCore():getBadHighlitedColor()
	end
	ISJumpToCursor.floorSprite:RenderGhostTileColor(x, y, z, hc:getR(), hc:getG(), hc:getB(), 0.8)
end

function ISJumpToCursor:new(sprite, northSprite, character, durationCall)
	local o = {}
	setmetatable(o, self)
	self.__index = self
	o:init()
	o:setSprite(sprite)
	o:setNorthSprite(northSprite)
	o.character = character
	o.player = character:getPlayerNum()
	o.noNeedHammer = true
	o.skipBuildAction = true
	o.durationCall = durationCall
	return o
end