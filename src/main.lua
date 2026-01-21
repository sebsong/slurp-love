require("game/settings")
require("engine/math")
require("engine/color")
require("engine/tilemap")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	local windowWidth, windowHeight = love.graphics.getDimensions()
	ScreenScale = math.min(windowWidth / ScreenWidth, windowHeight / ScreenHeight)

	Canvas = love.graphics.newCanvas(ScreenWidth, ScreenHeight)
	CanvasToScreenTransform = love.math.newTransform(
		(windowWidth - ScreenWidth * ScreenScale) / 2,
		(windowHeight - ScreenHeight * ScreenScale) / 2,
		0,
		ScreenScale,
		ScreenScale
	)

	ColorPalette = LoadColorPalette("assets/art/look-of-horror.hex")

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	local tileset = NewTileset("assets/art/tileset.png", 32)
	Tilemap = NewTilemap("assets/art/map.csv", tileset)

	-- TODO: offset world coords so 0, 0 is center of tilemap
	local tilemapPixelWidth, tilemapPixelHeight = GetPixelDimensions(Tilemap)
	-- WorldTransform = love.math.newTransform(tilemapPixelWidth / 2, tilemapPixelHeight / 2)
	WorldToTilemapTransform = love.math.newTransform()

	Camera = {
		transform = love.math.newTransform(),
		screenWidth = ScreenWidth,
		screenHeight = ScreenHeight,
	}

	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	local entitiesImageWidth = EntitiesImage:getWidth()
	local entitiesImageHeight = EntitiesImage:getHeight()

	local boatWidth, boatHeight = 32, 32
	BoatQuad = love.graphics.newQuad(0, 0, boatWidth, boatHeight, entitiesImageWidth, entitiesImageHeight)
	BoatTransform = love.math.newTransform(tilemapPixelWidth / 2, tilemapPixelHeight / 2)
	Speed = 0
	MaxSpeed = 75
	Acceleration = 2 * MaxSpeed
	Deceleration = Acceleration / 2
	RotSpeed = PI / 4

	Bgm = love.audio.newSource("assets/sound/bgm.ogg", "stream")
	Bgm:setVolume(0.3)
	Bgm:setLooping(true)
	Bgm:play()

	love.graphics.setPointSize(5)
	love.graphics.setBackgroundColor(0, 0, 0)
end

local function upPressed()
	return love.keyboard.isDown("up") or love.keyboard.isDown("w")
end

local function downPressed()
	return love.keyboard.isDown("down") or love.keyboard.isDown("s")
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if upPressed() or downPressed() then
		if upPressed() then
			Speed = Speed + Acceleration * dt
		end
		if downPressed() then
			Speed = Speed - Acceleration * dt
		end
	else
		if Speed > 0 then
			Speed = math.max(0, Speed - Deceleration * dt)
		elseif Speed < 0 then
			Speed = math.min(0, Speed + Deceleration * dt)
		end
	end
	if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		BoatTransform:rotate(-RotSpeed * dt)
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		BoatTransform:rotate(RotSpeed * dt)
	end

	if math.abs(Speed) > MaxSpeed then
		Speed = (Speed / math.abs(Speed)) * MaxSpeed
	end

	BoatTransform:translate(0, -Speed * dt)

	local boatX, boatY = BoatTransform:transformPoint(0, 0)
	Camera.transform:setTransformation(boatX, boatY)
end

local function getIntersectionTiles(tilemap, camera)
	local tileSize = tilemap.tileset.tileSize

	local cameraX, cameraY = camera.transform:transformPoint(0, 0)
	local startX, startY = cameraX - (camera.screenWidth / 2), cameraY - (camera.screenHeight / 2)
	local endX, endY = startX + camera.screenWidth, startY + camera.screenHeight

	local tilemapStartX, tilemapStartY = WorldToTilemapTransform:transformPoint(startX, startY)
	local tilemapEndX, tilemapEndY = WorldToTilemapTransform:transformPoint(endX, endY)
	local startRowIdx, endRowIdx = math.floor(tilemapStartY / tileSize) - 1, math.ceil(tilemapEndY / tileSize) + 1
	local startColIdx, endColIdx = math.floor(tilemapStartX / tileSize) - 1, math.ceil(tilemapEndX / tileSize) + 1
	return startRowIdx, endRowIdx, startColIdx, endColIdx
end

function love.draw()
	Canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.draw(BackgroundImage)

			love.graphics.push()
			-- love.graphics.applyTransform(ScreenTransform)
			love.graphics.applyTransform(WorldToTilemapTransform)
			local camX, camY = Camera.transform:transformPoint(0, 0)
			love.graphics.translate(-(camX - Camera.screenWidth / 2), -(camY - Camera.screenHeight / 2))
			local startRowIdx, endRowIdx, startColIdx, endColIdx = getIntersectionTiles(Tilemap, Camera)
			DrawTiles(Tilemap, startRowIdx, endRowIdx, startColIdx, endColIdx)

			love.graphics.applyTransform(BoatTransform)

			local _, _, boatWidth, boatHeight = BoatQuad:getViewport()
			love.graphics.draw(EntitiesImage, BoatQuad, 0, 0, 0, 1, 1, boatWidth / 2, boatHeight / 2)

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas, CanvasToScreenTransform)
end
