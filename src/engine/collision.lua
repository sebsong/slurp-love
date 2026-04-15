local collision = {}

local slurp_math = require("engine/math")

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
local collidables = {}

function collision.register(collidable)
	table.insert(collidables, collidable)
end

function collision.hitTest(x, y, collider, colliderPosition)
	local colliderX, colliderY = unpack(colliderPosition)
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

function collision.getPositionUpdate(collidable, targetPositionUpdate)
	local positionUpdate = targetPositionUpdate
	local position = getCollidablePosition(collidable)
	local x, y = unpack(position)
	local collider = collidable.collider
	local halfWidth, halfHeight = collider.width / 2, collider.height / 2
	local leftX, rightX, topY, bottomY = getRectExtents(x, y, halfWidth, halfHeight)
	for _, otherCollidable in ipairs(collidables) do
		if collidable == otherCollidable then
			goto continue
		end

		local targetPosition = { position[1] + positionUpdate[1], position[2] + positionUpdate[2] }

		local otherPosition = getCollidablePosition(otherCollidable)
		local otherCollider = otherCollidable.collider
		local targetX, targetY = unpack(targetPosition)

		local otherHalfWidth, otherHalfHeight = otherCollider.width / 2, otherCollider.height / 2
		local otherX, otherY = unpack(otherPosition)

		local targetLeftX, targetRightX, targetTopY, targetBottomY = getRectExtents(
			targetX, targetY, halfWidth, halfHeight
		)
		local otherLeftX, otherRightX, otherTopY, otherBottomY = getRectExtents(
			otherX, otherY, otherHalfWidth, otherHalfHeight
		)

		local isLeft = targetX < otherX
		local xIntersects
		if isLeft then
			xIntersects = targetRightX >= otherLeftX
		else
			xIntersects = targetLeftX <= otherRightX
		end

		local isAbove = targetY < otherY
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
				positionUpdate[1] = positionUpdate[1] + xCorrection
			else
				positionUpdate[2] = positionUpdate[2] + yCorrection
			end

			-- TODO: trigger collision callback
		end

		::continue::
	end


	return positionUpdate
end

function collision.clearAll()
	collidables = {}
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
