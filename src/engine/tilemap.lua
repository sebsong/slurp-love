require("engine/math")

local function getIntersectionTiles(tilemap, camera)
	local tileWidth, tileHeight = tilemap.tileset.tileWidth, tilemap.tileset.tileHeight

	if tilemap.isIsometric then
		-- TODO: this is a hack for isometric, need to actually intersect tiles with camera and return tiles instead of tile index ranges
		return 0, tilemap.height, 0, tilemap.width
	end

	local cameraX, cameraY = camera.transform:transformPoint(0, 0)
	local startX, startY = cameraX - (camera:getScreenWidth() / 2), cameraY - (camera:getScreenHeight() / 2)
	local endX, endY = startX + camera:getScreenWidth(), startY + camera:getScreenHeight()

	local tilemapStartX, tilemapStartY = tilemap.worldToTilemapTransform:transformPoint(startX, startY)
	local tilemapEndX, tilemapEndY = tilemap.worldToTilemapTransform:transformPoint(endX, endY)
	local startRowIdx, endRowIdx = math.floor(tilemapStartY / tileHeight) - 1, math.ceil(tilemapEndY / tileHeight) + 1
	local startColIdx, endColIdx = math.floor(tilemapStartX / tileWidth) - 1, math.ceil(tilemapEndX / tileWidth) + 1
	return startRowIdx, endRowIdx, startColIdx, endColIdx
end

local function draw(self, camera)
	local tileset = self.tileset
	local tileWidth, tileHeight = tileset.tileWidth, tileset.tileHeight
	local startRowIdx, endRowIdx, startColIdx, endColIdx = getIntersectionTiles(self, camera)

	for rowIdx = startRowIdx, endRowIdx - 1 do
		local rowYOffset = (rowIdx - 1) * tileHeight
		for colIdx = startColIdx, endColIdx - 1 do
			local rowTiles = self.tiles[rowIdx]
			if rowTiles then
				local tileId = rowTiles[colIdx]
				if tileId then
					local colXOffset = (colIdx - 1) * tileWidth
					local tileQuad = tileset.tileQuads[tileId]
					if tileQuad then
						local x, y = self.tilemapToWorldTransform:transformPoint(colXOffset, rowYOffset)
						love.graphics.draw(tileset.image, tileQuad, x, y)
					end
				end
			end
		end
	end
end

function NewTileset(imageFilePath, tileImageSize, tileGridWidth, tileGridHeight, isIsometric)
	local tileWidth = tileGridWidth
	local tileHeight = tileGridHeight
	if isIsometric then
		-- TODO: compute diagonal width and height
	end

	local image = love.graphics.newImage(imageFilePath)
	local tileQuads = {}
	local numTilesPerRow = image:getPixelWidth() / tileImageSize
	local numTilesPerCol = image:getPixelHeight() / tileImageSize
	local tileId = 0
	for rowIdx = 1, numTilesPerRow, 1 do
		local rowYOffset = (rowIdx - 1) * tileImageSize
		for colIdx = 1, numTilesPerCol, 1 do
			local colXOffset = (colIdx - 1) * tileImageSize
			tileQuads[tileId] = love.graphics.newQuad(colXOffset, rowYOffset, tileImageSize, tileImageSize, image)
			tileId = tileId + 1
		end
	end

	return {
		image = image,
		quads = tileQuads,
		tileWidth = tileWidth,
		tileHeight = tileHeight,
	}
end

function NewTilemap(csvFilepath, tileset, isIsometric)
	local tiles = {}
	for line in love.filesystem.lines(csvFilepath) do
		local rowTiles = {}
		for tileId in string.gmatch(line, "%-?%d+") do
			table.insert(rowTiles, tonumber(tileId))
		end
		table.insert(tiles, rowTiles)
	end

	local width
	local height
	if tiles then
		height = #tiles
		local firstRowTiles = tiles[1]
		if firstRowTiles then
			width = #firstRowTiles
		end
	end

	local tilemapPixelWidth, tilemapPixelHeight = width * tileset.tileWidth, height * tileset.tileWidth
	local worldToTilemapTransform = love.math.newTransform(tilemapPixelWidth / 2, tilemapPixelHeight / 2)
	local isIsometric = isIsometric or false
	if isIsometric then
		worldToTilemapTransform:rotate(-PI / 4)
		-- diagonal scaling sqrt(1^2 + 1^2)
		local diagonalScale = math.sqrt(tileset.tileWidth ^ 2 + tileset.tileHeight ^ 2)
		worldToTilemapTransform:scale(math.sqrt(2), math.sqrt(2))
		worldToTilemapTransform:shear(math.sqrt(2), math.sqrt(2))
	end
	local tilemapToWorldTransform = worldToTilemapTransform:inverse()

	return {
		tileset = tileset,
		tiles = tiles,
		width = width,
		height = height,
		isIsometric = isIsometric,
		worldToTilemapTransform = worldToTilemapTransform,
		tilemapToWorldTransform = tilemapToWorldTransform,

		draw = draw,
	}
end
