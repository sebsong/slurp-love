require("engine/math")

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

local function getPixelDimensions(tilemap)
	local tileSize = tilemap.tileset.tileSize
	return tilemap.width * tileSize, tilemap.height * tileSize
end

function NewTilemap(csvFilepath, tileset, isIsometric)
	local tilemap = {}
	tilemap.tileset = tileset
	tilemap.isIsometric = isIsometric or false
	local tiles = {}
	for line in love.filesystem.lines(csvFilepath) do
		local rowTiles = {}
		for tileId in string.gmatch(line, "%-?%d+") do
			table.insert(rowTiles, tonumber(tileId))
		end
		table.insert(tiles, rowTiles)
	end
	tilemap.tiles = tiles

	if tilemap.tiles then
		tilemap.height = #tilemap.tiles
		local firstRowTiles = tilemap.tiles[1]
		if firstRowTiles then
			tilemap.width = #firstRowTiles
		end
	end
	local tilemapPixelWidth, tilemapPixelHeight = getPixelDimensions(tilemap)
	tilemap.worldToTilemapTransform = love.math.newTransform(tilemapPixelWidth / 2, tilemapPixelHeight / 2)
	if tilemap.isIsometric then
		tilemap.worldToTilemapTransform:rotate(-PI / 4)
		-- diagonal scaling sqrt(1^2 + 1^2)
		tilemap.worldToTilemapTransform:scale(math.sqrt(2), math.sqrt(2))
	end
	tilemap.tilemapToWorldTransform = tilemap.worldToTilemapTransform:inverse()
	return tilemap
end

function DrawTiles(tilemap, startRowIdx, endRowIdx, startColIdx, endColIdx)
	local tileset = tilemap.tileset
	local tileSize = tileset.tileSize

	for rowIdx = startRowIdx, endRowIdx - 1 do
		local rowYOffset = (rowIdx - 1) * tileSize
		for colIdx = startColIdx, endColIdx - 1 do
			local rowTiles = tilemap.tiles[rowIdx]
			if rowTiles then
				local tileId = rowTiles[colIdx]
				if tileId then
					local colXOffset = (colIdx - 1) * tileSize
					local tileQuad = tileset.tileQuads[tileId]
					if tileQuad then
						local x, y = tilemap.tilemapToWorldTransform:transformPoint(colXOffset, rowYOffset)
						love.graphics.draw(tileset.image, tileQuad, x, y)
					end
				end
			end
		end
	end
end
