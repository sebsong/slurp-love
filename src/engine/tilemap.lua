function NewTileset(imageFilePath, tileSize)
	local tileset = {}
	tileset.image = love.graphics.newImage(imageFilePath)
	tileset.tileSize = tileSize
	tileset.tileQuads = {}

	local numTilesPerRow = tileset.image:getPixelWidth() / tileSize
	local numTilesPerCol = tileset.image:getPixelHeight() / tileSize
	local tileId = 0
	for rowIdx = 1, numTilesPerRow, 1 do
		local rowYOffset = (rowIdx - 1) * tileSize
		for colIdx = 1, numTilesPerCol, 1 do
			local colXOffset = (colIdx - 1) * tileSize
			tileset.tileQuads[tileId] = love.graphics.newQuad(colXOffset, rowYOffset, tileSize, tileSize, tileset.image)
			tileId = tileId + 1
		end
	end

	return tileset
end

function NewTilemap(csvFilepath, tileset)
	local tilemap = {}
	tilemap.tileset = tileset
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
						love.graphics.draw(tileset.image, tileQuad, colXOffset, rowYOffset)
					end
				end
			end
		end
	end
end

function GetPixelDimensions(tilemap)
	local tileSize = tilemap.tileset.tileSize
	return tilemap.width * tileSize, tilemap.height * tileSize
end
