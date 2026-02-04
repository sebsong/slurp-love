-- package types
local BASIC = 1
local BOULDER = 2
local TENTACLE = 3

local function applyEffect(self, boat)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == BOULDER then
		boat.maxSpeed = boat.maxSpeed / 2
	elseif tileId == TENTACLE then
	end
end

local function removeEffect(self, boat)
	local tileId = self.tileId
	if tileId == BASIC then
	elseif tileId == BOULDER then
		boat.maxSpeed = boat.maxSpeed * 2
	elseif tileId == TENTACLE then
	end
end

function NewPackage(tilemap, tileset, tileObject)
	local objColIdx, objRowIdx = tileObject.transform:transformPoint(0, 0)
	local colIdx, rowIdx = tilemap.tilemapIndexToWorldTransform:transformPoint(objColIdx, objRowIdx)
	local tileId = tileObject.tileId
	return {
		tileId = tileId,
		image = tileset.image,
		quad = tileset.quads[tileId],
		transform = love.math.newTransform(colIdx, rowIdx),

		applyEffect = applyEffect,
		removeEffect = removeEffect,
	}
end
