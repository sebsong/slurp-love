local collision = {}

local slurp_math = require("engine/math")
local set = require("engine/set")

-- collidable:
-- {
--	position: {x, y},
--	getPosition: (self) => {x, y},
--
-- 	collider: {
-- 		width: x,
-- 		height: y
-- 	}
-- }
-- local collidables = set.new()

-- function collision.register(collidable)
-- 	assert(collidable.collider ~= nil, "collidables must have a collider")
-- 	assert(collidable.position ~= nil or collidable.getPosition ~= nil, "collidables must have a position")
-- 	if not collidables:contains(collidable) then
-- 		collidable.collidingWith = set.new()
-- 		collidables:insert(collidable)
-- 	end
-- end

-- function collision.remove(collidable)
-- 	collidables:remove(collidable)
-- end

-- function collision.clearAll()
-- 	collidables = set.new()
-- end

function collision.hitTest(x, y, collider, transform)
	local colliderX, colliderY = transform:transformPoint(0, 0)
	local xMin, xMax = colliderX, colliderX + collider.width
	local yMin, yMax = colliderY, colliderY + collider.height

	return x >= xMin and x < xMax and y >= yMin and y < yMax
end

local function getCollidablePosition(collidable)
	if collidable.position then
		return collidable.position
	elseif collidable.getPosition then
		return collidable:getPosition()
	else
		error("Collidable must have a position")
	end
end

local function getRectExtents(x, y, halfWidth, halfHeight)
	return (x - halfWidth), (x + halfWidth), (y - halfHeight), (y + halfHeight)
end

function collision.getPositionUpdate(collidable, collidables, targetPositionUpdate)
	local positionUpdate = targetPositionUpdate
	local position = getCollidablePosition(collidable)
	local collider = collidable.collider
	local halfWidth, halfHeight = collider.width / 2, collider.height / 2

	for _, otherCollidable in ipairs(collidables) do
		if collidable == otherCollidable then
			goto continue
		end

		local targetPosition = position + positionUpdate

		local otherPosition = getCollidablePosition(otherCollidable)
		local otherCollider = otherCollidable.collider

		local otherHalfWidth, otherHalfHeight = otherCollider.width / 2, otherCollider.height / 2

		local targetLeftX, targetRightX, targetTopY, targetBottomY = getRectExtents(
			targetPosition.x, targetPosition.y, halfWidth, halfHeight
		)
		local otherLeftX, otherRightX, otherTopY, otherBottomY = getRectExtents(
			otherPosition.x, otherPosition.y, otherHalfWidth, otherHalfHeight
		)

		local isLeft = targetPosition.x < otherPosition.x
		local xIntersects
		if isLeft then
			xIntersects = targetRightX >= otherLeftX
		else
			xIntersects = targetLeftX <= otherRightX
		end

		local isAbove = targetPosition.y < otherPosition.y
		local yIntersects
		if isAbove then
			yIntersects = targetBottomY >= otherTopY
		else
			yIntersects = targetTopY <= otherBottomY
		end

		if xIntersects and yIntersects then
			local xCorrection = slurp_math.absMin(otherLeftX - targetRightX, otherRightX - targetLeftX)
			local yCorrection = slurp_math.absMin(otherTopY - targetBottomY, otherBottomY - targetTopY)

			if math.abs(xCorrection) <= math.abs(yCorrection) then
				positionUpdate.x = positionUpdate.x + xCorrection
			else
				positionUpdate.y = positionUpdate.y + yCorrection
			end

			if collidable.onCollision and not collidable.collidingWith:contains(otherCollidable) then
				collidable:onCollision(otherCollidable)
			end
			if otherCollidable.onCollision and not otherCollidable.collidingWith:contains(collidable) then
				otherCollidable:onCollision(collidable)
			end

			collidable.collidingWith:insert(otherCollidable)
			otherCollidable.collidingWith:insert(collidable)
		else
			collidable.collidingWith:remove(otherCollidable)
			otherCollidable.collidingWith:remove(collidable)
		end

		::continue::
	end


	return positionUpdate
end

function collision.drawTileColliders(tilemap, layerIndex)
	love.graphics.push()
	love.graphics.applyTransform(tilemap.tilemapIndexToWorldTransform)
	for rowIdx, row in ipairs(tilemap.layers[layerIndex].tiles) do
		for colIdx, tile in ipairs(row) do
			if tile.tileId then
				collision.drawCollider(
					{ width = 1, height = 1 },
					{ colIdx, rowIdx }
				)
			end
		end
	end
	love.graphics.pop()
end

function collision.drawCollider(collider, position)
	local x, y = unpack(position)
	local width, height = collider.width, collider.height
	local colliderVertices = {
		x - width / 2, y - height / 2,
		x + width / 2, y - height / 2,
		x + width / 2, y + height / 2,
		x - width / 2, y + height / 2,
	}

	love.graphics.polygon("line", unpack(colliderVertices))
end

return collision
