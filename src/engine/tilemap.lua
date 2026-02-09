-- Based on Tiled (https://www.mapeditor.org/)
require("engine/file")

local function getIntersectionTiles(tilemap, camera)
	local cameraX, cameraY = camera.transform:transformPoint(0, 0)
	local startX, startY = cameraX - (camera:getScreenWidth() / 2), cameraY - (camera:getScreenHeight() / 2)
	local endX, endY = startX + camera:getScreenWidth(), startY + camera:getScreenHeight()

	local startColIdx, startRowIdx
	local endColIdx, endRowIdx
	if tilemap.isIsometric then
		startColIdx, _ = tilemap.worldToTilemapIndexTransform:transformPoint(startX, startY)
		endColIdx, _ = tilemap.worldToTilemapIndexTransform:transformPoint(endX, endY)
		_, startRowIdx = tilemap.worldToTilemapIndexTransform:transformPoint(endX, startY)
		_, endRowIdx = tilemap.worldToTilemapIndexTransform:transformPoint(startX, endY)
	else
		startColIdx, startRowIdx = tilemap.worldToTilemapIndexTransform:transformPoint(startX, startY)
		endColIdx, endRowIdx = tilemap.worldToTilemapIndexTransform:transformPoint(endX, endY)
	end

	return
		math.floor(math.max(startColIdx, 1)),
		math.floor(math.min(startRowIdx, tilemap.width)),
		math.ceil(math.max(endColIdx, 1)),
		math.ceil(math.min(endRowIdx, tilemap.height))
end

local function drawTileLayer(tilemap, layerIndex, camera)
	local layer = tilemap.layers[layerIndex]
	local startColIdx, startRowIdx, endColIdx, endRowIdx = getIntersectionTiles(tilemap, camera)

	assert(startColIdx <= endColIdx)
	assert(startRowIdx <= endRowIdx)

	for rowIdx = startRowIdx, endRowIdx do
		for colIdx = startColIdx, endColIdx do
			local rowTiles = layer.tiles[rowIdx]
			if not rowTiles then
				goto continue
			end
			local tile = rowTiles[colIdx]
			if not tile then
				goto continue
			end
			local tilesetIndex = tile.tilesetIndex
			local tileId = tile.tileId
			if not tilesetIndex or not tileId then
				goto continue
			end
			local tileset = tilemap.tilesets[tilesetIndex]
			local tileQuad = tileset.quads[tileId]
			if not tileQuad then
				goto continue
			end

			local x, y = tilemap.tilemapIndexToWorldTransform:transformPoint(colIdx, rowIdx)
			local _, _, width, height = tileQuad:getViewport()
			love.graphics.draw(tileset.image, tileQuad, x - width / 2, y - height / 2)

			::continue::
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
	local numCols = image:getPixelWidth() / tileImageSize
	local numRows = image:getPixelHeight() / tileImageSize
	for rowIdx = 1, numRows, 1 do
		local rowYOffset = (rowIdx - 1) * tileImageSize
		for colIdx = 1, numCols, 1 do
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

local function getTilemapTransforms(tileWidth, tileHeight, width, height, isIsometric)
	local tilemapIndexToWorldTransform
	if isIsometric then
		local shearFactor = -(tileWidth - tileHeight) / (tileWidth + tileHeight)
		-- NOTE: shearing affects the scaling, need to adjust for that
		local shearCorrectionScale = 1 / math.sqrt(1 + shearFactor ^ 2)

		local tileScale = math.sqrt((tileWidth / 2) ^ 2 + (tileHeight / 2) ^ 2)
		tilemapIndexToWorldTransform = love.math.newTransform()
		tilemapIndexToWorldTransform:scale(tileScale, tileScale)
		tilemapIndexToWorldTransform:scale(shearCorrectionScale, shearCorrectionScale)
		tilemapIndexToWorldTransform:translate(0, -height / 2)
		tilemapIndexToWorldTransform:rotate(math.pi / 4)
		tilemapIndexToWorldTransform:shear(shearFactor, shearFactor)
	else
		tilemapIndexToWorldTransform = love.math.newTransform()
		tilemapIndexToWorldTransform:translate(-width / 2, -height / 2)
		tilemapIndexToWorldTransform:scale(tileWidth, tileHeight)
	end

	local worldToTilemapIndexTransform = tilemapIndexToWorldTransform:inverse()

	return tilemapIndexToWorldTransform, worldToTilemapIndexTransform
end

local function getTilesetIndex(gid, tilesetInfos)
	for i = #tilesetInfos, 1, -1 do
		local tilesetInfo = tilesetInfos[i]
		if gid >= tilesetInfo.firstgid then
			return i
		end
	end
	assert(false, string.format("Object gid: %s should map to a tileset", gid))
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
	local isIsometric = tilemapInfo.orientation == "isometric"

	local tilemapIndexToWorldTransform, worldToTilemapIndexTransform = getTilemapTransforms(
		tileWidth,
		tileHeight,
		width,
		height,
		isIsometric
	)

	local layers = {}
	for i, layer in ipairs(tilemapInfo.layers) do
		if layer.type == "tilelayer" then
			local tiles = {}
			for _ = 1, tilemapInfo.height do
				table.insert(tiles, {})
			end
			for _, chunk in ipairs(layer.chunks) do
				for j = 1, chunk.height do
					local rowIdx = chunk.y + j
					for i = 1, chunk.width do
						local colIdx = chunk.x + i
						if rowIdx > tilemapInfo.width or colIdx > tilemapInfo.height then
							goto continue
						end
						local gid = chunk.data[(j - 1) * chunk.width + (i - 1) + 1]
						if gid == 0 then
							tiles[rowIdx][colIdx] = {
								tilesetIndex = nil,
								tileId = nil,
							}
							goto continue
						end
						local tilesetIndex = getTilesetIndex(gid, tilesetInfos)
						local tileId = getTileId(gid, tilesetInfos[tilesetIndex])
						tiles[rowIdx][colIdx] = {
							tilesetIndex = tilesetIndex,
							tileId = tileId,
						}
						::continue::
					end
				end
			end

			layers[i] = {
				tiles = tiles,
			}
		elseif layer.type == "objectgroup" then
			local objects = {}
			for _, object in ipairs(layer.objects) do
				local colIdx = object.x / (tileHeight) + 1
				local rowIdx = object.y / (tileHeight) + 1
				local tilesetIndex = getTilesetIndex(object.gid, tilesetInfos)
				local tileset = tilesets[tilesetIndex]
				local tileId = getTileId(object.gid, tilesetInfos[tilesetIndex])
				local worldX, worldY = tilemapIndexToWorldTransform:transformPoint(colIdx, rowIdx)
				local quad = tileset.quads[tileId]
				local _, _, width, height = quad:getViewport()
				table.insert(objects, {
					shouldDraw = true,
					image = tileset.image,
					quad = quad,
					offsetX = -width / 2,
					offsetY = -height,
					transform = love.math.newTransform(worldX, worldY),

					id = object.id,
					tilesetIndex = tilesetIndex,
					tileId = tileId,
					properties = object.properties,
				})
			end

			layers[i] = {
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

		tilemapIndexToWorldTransform = tilemapIndexToWorldTransform,
		worldToTilemapIndexTransform = worldToTilemapIndexTransform,

		tilesets = tilesets,
		layers = layers,

		draw = draw,
	}
end
