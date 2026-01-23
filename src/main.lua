require("engine/settings")
require("engine/math")
require("engine/color")
require("engine/tilemap")
Camera = require("engine/camera")
require("game/boat")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	local windowWidth, windowHeight = love.graphics.getDimensions()
	ScreenScale = math.min(windowWidth / TargetCanvasWidth, windowHeight / TargetCanvasHeight)

	-- if ScreenScale > 1 then
	-- if display is smaller than the canvas, we can't enforce integer scaling
	-- ScreenScale = math.floor(ScreenScale)
	-- end

	local canvasWidth = TargetCanvasWidth * ScreenScale
	local canvasHeight = TargetCanvasHeight * ScreenScale
	Canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
	CanvasToScreenTransform = love.math.newTransform(
		(windowWidth - canvasWidth) / 2,
		(windowHeight - canvasHeight) / 2,
		0
	)

	ColorPalette = LoadColorPalette("assets/art/look-of-horror.hex")

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	local tileset = NewTileset("assets/art/tileset.png", 16, 14) -- TODO: maybe switch to reading lua exported tiled files to get the grid size info
	Tilemap = NewTilemap("assets/art/map.csv", tileset, true)

	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	Boat = NewBoat(EntitiesImage)

	Bgm = love.audio.newSource("assets/sound/bgm.ogg", "stream")
	Bgm:setVolume(0.2)
	Bgm:setLooping(true)
	Bgm:play()

	love.graphics.setPointSize(5)
	love.graphics.setBackgroundColor(0, 0, 0)
end

function love.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		Camera:toggleZoom()
	end
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	Boat:update(dt)

	local boatX, boatY = Boat.transform:transformPoint(0, 0)
	Camera.transform:setTransformation(boatX, boatY)
end

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

function love.draw()
	Canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.push()
			love.graphics.scale(ScreenScale, ScreenScale)

			love.graphics.draw(BackgroundImage)

			love.graphics.scale(Camera.zoom, Camera.zoom)

			local camX, camY = Camera.transform:transformPoint(0, 0)
			local worldToCanvasTransform = love.math.newTransform(
				-(camX - Camera:getScreenWidth() / 2),
				-(camY - Camera:getScreenHeight() / 2)
			)
			love.graphics.applyTransform(worldToCanvasTransform)

			local startRowIdx, endRowIdx, startColIdx, endColIdx = getIntersectionTiles(Tilemap, Camera)
			DrawTiles(Tilemap, startRowIdx, endRowIdx, startColIdx, endColIdx)

			Boat:draw()

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas, CanvasToScreenTransform)
end
