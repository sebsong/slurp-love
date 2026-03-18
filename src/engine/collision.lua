local slurp_math = require("engine/math")

local collision = {}

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

function collision.intersects(collider, position, otherCollider, otherPosition)
	local w1, h1 = collider.width, collider.height
	local x1, y1 = unpack(position)

	local w2, h2 = otherCollider.width, otherCollider.height
	local x2, y2 = unpack(otherPosition)

	local isLeft = x1 < x2
	local xIntersects
	if isLeft then
		xIntersects = (x1 + w1 / 2) >= (x2 - w2 / 2)
	else
		xIntersects = (x1 - w1 / 2) <= (x2 + w2 / 2)
	end

	local isAbove = y1 < y2
	local yIntersects
	if isAbove then
		yIntersects = (y1 + h1 / 2) >= (y2 - h2 / 2)
	else
		yIntersects = (y1 - h1 / 2) <= (y2 + h2 / 2)
	end

	return xIntersects and yIntersects
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
			if rightX <= otherLeftX then
				positionUpdate[1] = slurp_math.absMin(otherLeftX - rightX, positionUpdate[1])
			elseif leftX >= otherRightX then
				positionUpdate[1] = slurp_math.absMin(otherRightX - leftX, positionUpdate[1])
			end

			if bottomY <= otherTopY then
				positionUpdate[2] = slurp_math.absMin(otherTopY - bottomY, positionUpdate[2])
			elseif topY >= otherBottomY then
				positionUpdate[2] = slurp_math.absMin(otherBottomY - topY, positionUpdate[2])
			end

			-- TODO: trigger collision callback
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
