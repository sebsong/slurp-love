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

local function draw(self, camera)
	local tileset = self.tileset
	local startRowIdx, endRowIdx, startColIdx, endColIdx = getIntersectionTiles(self, camera)

	local tileX, tileY
	for rowIdx = startRowIdx, endRowIdx - 1 do
		for colIdx = startColIdx, endColIdx - 1 do
			local rowTiles = self.tiles[rowIdx]
			if rowTiles then
				local tileId = rowTiles[colIdx]
				if tileId then
					if self.isIsometric then
						tileX = -(rowIdx - 1) * self.tileWidth / 2 + (colIdx - 1) * self.tileWidth / 2
						tileY = (rowIdx - 1) * self.tileHeight / 2 + (colIdx - 1) * self.tileHeight / 2
					else
						tileX = (colIdx - 1) * self.tileWidth
						tileY = (rowIdx - 1) * self.tileHeight
					end
					local tileQuad = tileset.quads[tileId]
					if tileQuad then
						local x, y = self.tilemapToWorldTransform:transformPoint(tileX, tileY)
						local _, _, width, height = tileQuad:getViewport()
						love.graphics.draw(tileset.image, tileQuad, x - width / 2, y - height / 2)
					end
				end
			end
		end
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

function NewTilemapLua(luaFilepath, tileset, layerIndex)
	AssertFileExt(luaFilepath, ".lua")

	local tilemapInfo = require(StripFileExtension(luaFilepath))
	local tiles = {}
	for _ = 1, tilemapInfo.height do
		table.insert(tiles, {})
	end
	for _, chunk in ipairs(tilemapInfo.layers[layerIndex].chunks) do
		for j = 1, chunk.height do
			local rowIdx = chunk.y + j
			for i = 1, chunk.width do
				local colIdx = chunk.x + i
				if rowIdx <= tilemapInfo.width and colIdx <= tilemapInfo.height then
					tiles[rowIdx][colIdx] = chunk.data[(j - 1) * chunk.width + (i - 1) + 1]
				end
			end
		end
	end

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

	return {
		tileset = tileset,
		tiles = tiles,
		width = width,
		height = height,
		tileWidth = tileWidth,
		tileHeight = tileHeight,
		isIsometric = isIsometric,
		worldToTilemapTransform = worldToTilemapTransform,
		tilemapToWorldTransform = tilemapToWorldTransform,

		draw = draw,
	}
end

-- NOTE: assumes that layer index matches tileset index and that only 1 tileset is used per layer
-- TODO: maybe should just process this with the tilemap and make it a property on the tilemap? need tilemap -> world transform
function NewObjectMap(luaFilepath, layerIndex)
	AssertFileExt(luaFilepath, ".lua")
	local tilemapInfo = require(StripFileExtension(luaFilepath))
	local tilesetInfo = tilemapInfo.tilesets[layerIndex]
	local objectGroup = tilemapInfo.layers[layerIndex]

	local objects = {}
	for _, object in ipairs(objectGroup.objects) do
		local objX, objY = object.x, object.y
		table.insert(objects, {
			transform = love.math.newTransform(),
		})
	end

	return objects
end
