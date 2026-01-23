require("engine/math")

local function getIntersectionTiles(tilemap, camera)
	local tileSize = tilemap.tileset.tileSize

	if tilemap.isIsometric then
		-- TODO: this is a hack for isometric, need to actually intersect tiles with camera and return tiles instead of tile index ranges
		return 0, tilemap.height, 0, tilemap.width
	end

	local cameraX, cameraY = camera.transform:transformPoint(0, 0)
	local startX, startY = cameraX - (camera:getScreenWidth() / 2), cameraY - (camera:getScreenHeight() / 2)
	local endX, endY = startX + camera:getScreenWidth(), startY + camera:getScreenHeight()

	local tilemapStartX, tilemapStartY = tilemap.worldToTilemapTransform:transformPoint(startX, startY)
	local tilemapEndX, tilemapEndY = tilemap.worldToTilemapTransform:transformPoint(endX, endY)
	local startRowIdx, endRowIdx = math.floor(tilemapStartY / tileSize) - 1, math.ceil(tilemapEndY / tileSize) + 1
	local startColIdx, endColIdx = math.floor(tilemapStartX / tileSize) - 1, math.ceil(tilemapEndX / tileSize) + 1
	return startRowIdx, endRowIdx, startColIdx, endColIdx
end

local function draw(self, camera)
	local tileset = self.tileset
	local tileSize = tileset.tileSize
	local startRowIdx, endRowIdx, startColIdx, endColIdx = getIntersectionTiles(self, camera)

	for rowIdx = startRowIdx, endRowIdx - 1 do
		local rowYOffset = (rowIdx - 1) * tileSize
		for colIdx = startColIdx, endColIdx - 1 do
			local rowTiles = self.tiles[rowIdx]
			if rowTiles then
				local tileId = rowTiles[colIdx]
				if tileId then
					local colXOffset = (colIdx - 1) * tileSize
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

function NewTileset(imageFilePath, tileImageSize, tileGridSize)
	local tileset = {}
	tileset.image = love.graphics.newImage(imageFilePath)
	tileset.tileSize = tileGridSize
	tileset.tileQuads = {}

	local numTilesPerRow = tileset.image:getPixelWidth() / tileImageSize
	local numTilesPerCol = tileset.image:getPixelHeight() / tileImageSize
	local tileId = 0
	for rowIdx = 1, numTilesPerRow, 1 do
		local rowYOffset = (rowIdx - 1) * tileImageSize
		for colIdx = 1, numTilesPerCol, 1 do
			local colXOffset = (colIdx - 1) * tileImageSize
			tileset.tileQuads[tileId] = love.graphics.newQuad(colXOffset, rowYOffset, tileImageSize, tileImageSize,
				tileset.image)
			tileId = tileId + 1
		end
	end

	return tileset
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

	local tileSize = tileset.tileSize
	local tilemapPixelWidth, tilemapPixelHeight = width * tileSize, height * tileSize
	local worldToTilemapTransform = love.math.newTransform(tilemapPixelWidth / 2, tilemapPixelHeight / 2)
	local isIsometric = isIsometric or false
	if isIsometric then
		worldToTilemapTransform:rotate(-PI / 4)
		-- diagonal scaling sqrt(1^2 + 1^2)
		worldToTilemapTransform:scale(math.sqrt(2), math.sqrt(2))
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
