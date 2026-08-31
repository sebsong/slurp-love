-- Based on Tiled (https://www.mapeditor.org/)

local File = require("engine.file")
local Set = require("engine.set")
local Sprite = require("engine.sprite")
local Vec2 = require("engine.vec2")

---@class Tilemap
---@field width integer
---@field height integer
---@field tileWidth integer
---@field tileHeight integer
---@field isIsometric boolean
---@field worldToTilemapIndexTransform love.Transform
---@field tilemapIndexToWorldTransform love.Transform
-- ---@field tilesets Tileset[]
---@field layers Layer[]
local Tilemap = {}

---@class Tileset
---@field image love.Image
---@field quads love.Quad[]

---@alias Layer TileLayer | ObjectLayer

---@class TileLayer
---@field tiles Tile[]
---@field properties table

---@class ObjectLayer
---@field objects TileObject
---@field properties table

---@class Tile
---@field tilesetIndex integer
---@field tilesetName string
---@field tileId integer
---@field position Vec2
---@field worldRowIdx integer
---@field zIndex integer
---@field zIndexOffset integer
---@field collider Collider
---@field collidingWith Set

---@class TileObject
---@field sprite Sprite
---@field transform love.Transform
---@field id integer
---@field tilesetName string
---@field tileId integer
---@field properties table

---@param tilemap Tilemap
---@param tiles Tile[]
---@param camera Camera
---@return Tile[]
function Tilemap.getIntersectionTiles(tilemap, tiles, camera)
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

    startColIdx = math.floor(math.max(startColIdx, 1))
    startRowIdx = math.floor(math.min(startRowIdx, tilemap.width))
    endColIdx = math.ceil(math.max(endColIdx, 1))
    endRowIdx = math.ceil(math.min(endRowIdx, tilemap.height))

    local intersectionTiles = {}

    for rowIdx = startRowIdx, endRowIdx do
        for colIdx = startColIdx, endColIdx do
            local rowTiles = tiles[rowIdx]
            if not rowTiles then
                goto continue
            end
            local tile = rowTiles[colIdx]
            if not tile or not tile.tileId then
                goto continue
            end

            table.insert(intersectionTiles, tile)

            ::continue::
        end
    end

    return intersectionTiles
end

---@param imageFilePath string
---@param tileWidth integer
---@param tileHeight integer
---@return Tileset
function Tilemap.newTileset(imageFilePath, tileWidth, tileHeight)
    local image = love.graphics.newImage(imageFilePath)
    local tileQuads = {}
    local numCols = image:getPixelWidth() / tileWidth
    local numRows = image:getPixelHeight() / tileHeight
    for rowIdx = 1, numRows, 1 do
        local rowYOffset = (rowIdx - 1) * tileHeight
        for colIdx = 1, numCols, 1 do
            local colXOffset = (colIdx - 1) * tileWidth
            local tileQuad = love.graphics.newQuad(colXOffset, rowYOffset, tileWidth, tileHeight, image)
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
        tilemapIndexToWorldTransform:translate(0, (-height / 2))
        tilemapIndexToWorldTransform:rotate(math.pi / 4)
        tilemapIndexToWorldTransform:scale(shearCorrectionScale, shearCorrectionScale)
        tilemapIndexToWorldTransform:shear(shearFactor, shearFactor)
    else
        tilemapIndexToWorldTransform = love.math.newTransform()
        tilemapIndexToWorldTransform:translate(-width / 2, -height / 2)
        tilemapIndexToWorldTransform:scale(tileWidth, tileHeight)
    end

    local worldToTilemapIndexTransform = tilemapIndexToWorldTransform:inverse()

    return tilemapIndexToWorldTransform, worldToTilemapIndexTransform
end

local function getTilesetInfo(gid, tilesetInfos)
    for i = #tilesetInfos, 1, -1 do
        local tilesetInfo = tilesetInfos[i]
        if gid >= tilesetInfo.firstgid then
            return i, tilesetInfo
        end
    end
    error(("Object gid: %s should map to a tileset"):format(gid))
end

local function getTileId(gid, tilesetInfo)
    return gid - tilesetInfo.firstgid + 1
end

-- the diagonal rows in tilemap space representing horizontal rows in world space
--     *		1
--   *   *		2 (1, 2) => 2, (2, 1) => 2
-- *   *   * 	3
---@param colIdx integer
---@param rowIdx integer
---@return integer
function Tilemap.getWorldRowIdx(colIdx, rowIdx)
    return (colIdx + rowIdx) - 1
end

local function insertTile(tiles, gid, tilesetInfos, rowIdx, colIdx, zIndexOffset)
    if not tiles[rowIdx] then
        tiles[rowIdx] = {}
    end

    if gid == 0 then
        tiles[rowIdx][colIdx] = {
            tilesetIndex = nil,
            tileId = nil,
        }
        goto continue
    end
    local tilesetIndex, tilesetInfo = getTilesetInfo(gid, tilesetInfos)
    local tileId = getTileId(gid, tilesetInfos[tilesetIndex])
    local worldRowIdx = Tilemap.getWorldRowIdx(colIdx, rowIdx)
    tiles[rowIdx][colIdx] = {
        tilesetIndex = tilesetIndex,
        tilesetName = tilesetInfo.name,
        tileId = tileId,

        -- TODO: initialize collision info somewhere else?
        position = Vec2.new(colIdx, rowIdx),
        worldRowIdx = worldRowIdx,
        zIndex = worldRowIdx,
        zIndexOffset = zIndexOffset,
        collider = { width = 1, height = 1 },
        collidingWith = Set.new(),
    }
    ::continue::
end

-- NOTE: tilesets must match order of tilesets in tilemap
-- NOTE: tilesets and layers are 1:1
---@param luaFilepath string
---@return Tilemap
function Tilemap.newTilemapLua(luaFilepath)
    File.assertFileExtension(luaFilepath, ".lua")

    local tilemapInfo = require(File.stripFileExtension(luaFilepath))

    -- TODO: can we process tilesets here?
    local tilesetInfos = tilemapInfo.tilesets

    local width = tilemapInfo.width
    local height = tilemapInfo.height
    local tileWidth = tilemapInfo.tilewidth
    local tileHeight = tilemapInfo.tileheight
    local isIsometric = tilemapInfo.orientation == "isometric"

    local tilemapIndexToWorldTransform, worldToTilemapIndexTransform =
        getTilemapTransforms(tileWidth, tileHeight, width, height, isIsometric)

    local layers = {}
    for _, layer in ipairs(tilemapInfo.layers) do
        local zIndexOffset = layer.properties.zIndexOffset or 0
        if layer.type == "tilelayer" then
            local tiles = {}
            if layer.chunks then
                for _, chunk in ipairs(layer.chunks) do
                    for j = 1, chunk.height do
                        local rowIdx = chunk.y + j
                        for i = 1, chunk.width do
                            local colIdx = chunk.x + i
                            local gid = chunk.data[(j - 1) * chunk.width + (i - 1) + 1]
                            insertTile(tiles, gid, tilesetInfos, rowIdx, colIdx, zIndexOffset)
                        end
                    end
                end
            else
                for rowIdx = 1, width do
                    for colIdx = 1, height do
                        local gid = layer.data[(rowIdx - 1) * width + (colIdx - 1) + 1] or 0
                        insertTile(tiles, gid, tilesetInfos, rowIdx, colIdx, zIndexOffset)
                    end
                end
            end

            layers[layer.name] = {
                tiles = tiles,
                properties = layer.properties,
            }
        elseif layer.type == "objectgroup" then
            local objects = {}
            for _, object in ipairs(layer.objects) do
                local colIdx = object.x / tileHeight
                local rowIdx = object.y / tileHeight
                local tilesetIndex, tilesetInfo = getTilesetInfo(object.gid, tilesetInfos)
                local tileId = getTileId(object.gid, tilesetInfos[tilesetIndex])
                local worldX, worldY = tilemapIndexToWorldTransform:transformPoint(colIdx, rowIdx)
                local worldRowIdx = Tilemap.getWorldRowIdx(colIdx, rowIdx)

                -- TODO: maybe we shouldn't handle this in the tilemap
                table.insert(objects, {
                    id = object.id,
                    tilesetName = tilesetInfo.name,
                    tileId = tileId,
                    properties = object.properties,

                    transform = love.math.newTransform(worldX, worldY),
                    zIndex = worldRowIdx,
                    zIndexOffset = zIndexOffset,
                })
            end

            table.sort(objects, function(o1, o2)
                return o1.zIndex + o1.zIndexOffset < o2.zIndex + o2.zIndexOffset
            end)

            layers[layer.name] = {
                objects = objects,
                properties = layer.properties,
            }
        else
            error(("unsupported tile layer type: %s"):format(layer.type))
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

        layers = layers,
    }
end

return Tilemap
