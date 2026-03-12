local collision = {}

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
