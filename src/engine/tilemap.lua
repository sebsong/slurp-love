-- Based on Tiled (https://www.mapeditor.org/)
require("engine/file")
require("engine/math")

local function getIntersectionTiles(tilemap, camera)
	local tileWidth, tileHeight = tilemap.tileWidth, tilemap.tileHeight

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

local function drawTileLayer(tilemap, layerIndex, camera)
	local layer = tilemap.layers[layerIndex]
	local tileset = layer.tileset
	local startRowIdx, endRowIdx, startColIdx, endColIdx = getIntersectionTiles(tilemap, camera)

	local tileX, tileY
	for rowIdx = startRowIdx, endRowIdx - 1 do
		for colIdx = startColIdx, endColIdx - 1 do
			local rowTiles = layer.tiles[rowIdx]
			if rowTiles then
				local tileId = rowTiles[colIdx]
				if tileId then
					if tilemap.isIsometric then
						tileX = -(rowIdx - 1) * tilemap.tileWidth / 2 + (colIdx - 1) * tilemap.tileWidth / 2
						tileY = (rowIdx - 1) * tilemap.tileHeight / 2 + (colIdx - 1) * tilemap.tileHeight / 2
					else
						tileX = (colIdx - 1) * tilemap.tileWidth
						tileY = (rowIdx - 1) * tilemap.tileHeight
					end
					local tileQuad = tileset.quads[tileId]
					if tileQuad then
						local x, y = tilemap.tilemapToWorldTransform:transformPoint(tileX, tileY)
						local _, _, width, height = tileQuad:getViewport()
						love.graphics.draw(tileset.image, tileQuad, x - width / 2, y - height / 2)
					end
				end
			end
		end
	end
end

local function drawObjectLayer(tilemap, layerIndex, camera)
	assert(false, "TODO implement")
end

local function draw(self, layerIndex, camera)
	local layer = self.layers[layerIndex]
	if layer.tiles then
		drawTileLayer(self, layerIndex, camera)
	elseif layer.objects then
		drawObjectLayer(self, layerIndex, camera)
	else
		assert(false, string.format("Layer should have tiles or objects: %s", layer))
	end
end

function NewTileset(imageFilePath, tileImageSize)
	local image = love.graphics.newImage(imageFilePath)
	local tileQuads = {}
	local numTilesPerRow = image:getPixelWidth() / tileImageSize
	local numTilesPerCol = image:getPixelHeight() / tileImageSize
	for rowIdx = 1, numTilesPerRow, 1 do
		local rowYOffset = (rowIdx - 1) * tileImageSize
		for colIdx = 1, numTilesPerCol, 1 do
			local colXOffset = (colIdx - 1) * tileImageSize
			local tileQuad = love.graphics.newQuad(colXOffset, rowYOffset, tileImageSize, tileImageSize, image)
			table.insert(tileQuads, tileQuad)
		end
	end

	return {
		image = image,
		quads = tileQuads,
	}
end

local function getTilemapTransforms(tilemapPixelWidth, tilemapPixelHeight, isIsometric)
	local worldToTilemapTransform = love.math.newTransform(tilemapPixelWidth / 2, tilemapPixelHeight / 2)
	if isIsometric then
		worldToTilemapTransform:translate(-tilemapPixelWidth / 2, 0)
	end
	local tilemapToWorldTransform = worldToTilemapTransform:inverse()
	return worldToTilemapTransform, tilemapToWorldTransform
end


-- NOTE: doesn't support layers currently
function NewTilemapCsv(csvFilepath, tileset, isIsometric, tileGridWidth, tileGridHeight)
	AssertFileExt(csvFilepath, ".csv")

	local tiles = {}
	for line in love.filesystem.lines(csvFilepath) do
		local rowTiles = {}
		for tileId in string.gmatch(line, "%-?%d+") do
			table.insert(rowTiles, tonumber(tileId) + 1) -- Csv tile ids are 0-indexed while lua is 1-indexed
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

	local tilemapPixelWidth, tilemapPixelHeight = width * tileGridWidth, height * tileGridHeight
	local isIsometric = isIsometric or false
	local worldToTilemapTransform, tilemapToWorldTransform = getTilemapTransforms(
		tilemapPixelWidth,
		tilemapPixelHeight,
		isIsometric
	)

	return {
		tileset = tileset,
		tiles = tiles,
		width = width,
		height = height,
		tileWidth = tileGridWidth,
		tileHeight = tileGridHeight,
		isIsometric = isIsometric,
		worldToTilemapTransform = worldToTilemapTransform,
		tilemapToWorldTransform = tilemapToWorldTransform,

		draw = draw,
	}
end

local function getTilesetIndex(gid, tilesetInfos)
	for i = #tilesetInfos, 1, -1 do
		local tilesetInfo = tilesetInfos[i]
		if gid >= tilesetInfo.firstgid then
			return i
		end
	end
	assert(false, string.format("Object gid: %s should map to a tileset"), gid)
end

local function getTileId(gid, tilesetInfo)
	return gid - tilesetInfo.firstgid + 1
end

-- NOTE: tilesets must match order of tilesets in tilemap
-- NOTE: tilesets and layers are 1:1
function NewTilemapLua(luaFilepath, tilesets)
	AssertFileExt(luaFilepath, ".lua")

	local tilemapInfo = require(StripFileExtension(luaFilepath))

	-- TODO: can we process tilesets here?
	local tilesetInfos = tilemapInfo.tilesets

	local width = tilemapInfo.width
	local height = tilemapInfo.height
	local tileWidth = tilemapInfo.tilewidth
	local tileHeight = tilemapInfo.tileheight
	local tilemapPixelWidth, tilemapPixelHeight = width * tileWidth, height * tileHeight
	local isIsometric = tilemapInfo.orientation == "isometric"
	local worldToTilemapTransform, tilemapToWorldTransform = getTilemapTransforms(
		tilemapPixelWidth,
		tilemapPixelHeight,
		isIsometric
	)

	local layers = {}
	for i, layer in ipairs(tilemapInfo.layers) do
		if layer.type == "tilelayer" then
			local firstTileGid = layer.chunks[1].data[1]
			local tilesetIndex = getTilesetIndex(firstTileGid, tilesetInfos)
			local tilesetInfo = tilesetInfos[tilesetIndex]
			local tiles = {}
			for _ = 1, tilemapInfo.height do
				table.insert(tiles, {})
			end
			for _, chunk in ipairs(layer.chunks) do
				for j = 1, chunk.height do
					local rowIdx = chunk.y + j
					for i = 1, chunk.width do
						local colIdx = chunk.x + i
						if rowIdx <= tilemapInfo.width and colIdx <= tilemapInfo.height then
							local gid = chunk.data[(j - 1) * chunk.width + (i - 1) + 1]
							tiles[rowIdx][colIdx] = getTileId(gid, tilesetInfo)
						end
					end
				end
			end

			layers[i] = {
				tileset = tilesets[tilesetIndex],
				tiles = tiles,
			}
		elseif layer.type == "objectgroup" then
			local firstObjectGid = layer.objects[1].gid
			local tilesetIndex = getTilesetIndex(firstObjectGid, tilesetInfos)
			local tilesetInfo = tilesetInfos[tilesetIndex]

			local objects = {}
			for _, object in ipairs(layer.objects) do
				table.insert(objects, {
					tileId = getTileId(object.gid, tilesetInfo),
					transform = love.math.newTransform(object.x, object.y),
				})
			end
			layers[i] = {
				tileset = tilesets[tilesetIndex],
				objects = objects,
			}
		end
	end
	return {
		width = width,
		height = height,
		tileWidth = tileWidth,
		tileHeight = tileHeight,
		isIsometric = isIsometric,
		worldToTilemapTransform = worldToTilemapTransform,
		tilemapToWorldTransform = tilemapToWorldTransform,

		layers = layers,

		draw = draw,
	}
end
