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

function NewTilemap(csvFilepath)
	local tilemap = {}
	for line in love.filesystem.lines(csvFilepath) do
		local rowTiles = {}
		for tileId in string.gmatch(line, "%-?%d+") do
			table.insert(rowTiles, tonumber(tileId))
		end
		table.insert(tilemap, rowTiles)
	end
	return tilemap
end

function DrawTilemap(tilemap, tileset)
	local tileSize = tileset.tileSize
	for rowIdx, rowTiles in ipairs(tilemap) do
		local rowYOffset = (rowIdx - 1) * tileSize
		for colIdx, tileId in ipairs(rowTiles) do
			local colXOffset = (colIdx - 1) * tileSize
			local tileQuad = tileset.tileQuads[tileId]
			if tileQuad then
				love.graphics.draw(tileset.image, tileQuad, colXOffset, rowYOffset)
			end
		end
	end
end
