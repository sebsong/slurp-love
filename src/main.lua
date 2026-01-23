require("engine/settings")
require("engine/math")
require("engine/color")
require("engine/tilemap")
Camera = require("engine/camera")

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

	local tileset = NewTileset("assets/art/tileset.png", 16)
	Tilemap = NewTilemap("assets/art/map.csv", tileset, true)

	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	local entitiesImageWidth = EntitiesImage:getWidth()
	local entitiesImageHeight = EntitiesImage:getHeight()

	local numBoatQuads = 16
	local boatWidth, boatHeight = 16, 16
	BoatQuads = {}
	for i = 1, numBoatQuads do
		local boatQuad = love.graphics.newQuad((6 + i - 1) * 16, 2 * 16, boatWidth, boatHeight, entitiesImageWidth,
			entitiesImageHeight)
		table.insert(BoatQuads, boatQuad)
	end
	BoatQuad = BoatQuads[1]
	BoatTransform = love.math.newTransform()
	Speed = 0
	MaxSpeed = 75
	MaxBackwardsSpeed = MaxSpeed * 0.5
	Acceleration = 2 * MaxSpeed
	Deceleration = Acceleration / 4
	Rot = 0
	RotSpeed = PI / 4

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

	local didMove = false
	if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
		Speed = Speed + Acceleration * dt
		didMove = true
	end
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
		local acceleration = Deceleration
		if Speed > 0 then
			acceleration = acceleration * 2
		end
		Speed = Speed - acceleration * dt
		didMove = true
	end

	if not didMove then
		if Speed > 0 then
			Speed = math.max(0, Speed - Deceleration * dt)
		elseif Speed < 0 then
			Speed = math.min(0, Speed + Deceleration * dt)
		end
	end

	if Speed > 0 and Speed > MaxSpeed then
		Speed = MaxSpeed
	elseif Speed < 0 and Speed < -MaxBackwardsSpeed then
		Speed = -MaxBackwardsSpeed
	end

	if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		Rot = Rot - RotSpeed * dt
		BoatTransform:rotate(-RotSpeed * dt)
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		Rot = Rot + RotSpeed * dt
		BoatTransform:rotate(RotSpeed * dt)
	end

	local rotSegmentLength = 2 * PI / #BoatQuads
	local boatQuadIdx = math.floor(
		(
			((Rot + (rotSegmentLength / 2)) % (2 * PI)) /
			(rotSegmentLength)
		)
	) + 1
	BoatQuad = BoatQuads[boatQuadIdx]

	BoatTransform:translate(0, -Speed * dt)

	local boatX, boatY = BoatTransform:transformPoint(0, 0)
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

			love.graphics.push()
			local boatX, boatY = BoatTransform:transformPoint(0, 0)
			local _, _, boatWidth, boatHeight = BoatQuad:getViewport()
			love.graphics.draw(EntitiesImage, BoatQuad, boatX, boatY, 0, 1, 1, boatWidth / 2, boatHeight / 2)
			love.graphics.pop()

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas, CanvasToScreenTransform)
end
