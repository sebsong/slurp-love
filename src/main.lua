require("engine/settings")
require("engine/color")
require("engine/tilemap")
require("engine/camera")
require("game/boat")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	local windowWidth, windowHeight = love.graphics.getDimensions()
	ScreenScale = math.min(windowWidth / BaseCanvasWidth, windowHeight / BaseCanvasHeight)

	-- if ScreenScale > 1 then
	-- if display is smaller than the canvas, we can't enforce integer scaling
	-- ScreenScale = math.floor(ScreenScale)
	-- end

	local canvasWidth = BaseCanvasWidth * ScreenScale
	local canvasHeight = BaseCanvasHeight * ScreenScale
	Canvas = love.graphics.newCanvas(canvasWidth, canvasHeight)
	CanvasToScreenTransform = love.math.newTransform(
		(windowWidth - canvasWidth) / 2,
		(windowHeight - canvasHeight) / 2,
		0
	)

	Camera = NewCamera()

	ColorPalette = LoadColorPalette("assets/art/look-of-horror.hex")

	BackgroundImage = love.graphics.newImage("assets/art/background.png")

	local tileset = NewTileset("assets/art/tileset.png", 16, 14) -- TODO: maybe switch to reading lua exported tiled files to get the grid size info
	Tilemap = NewTilemap("assets/art/map.csv", tileset, true)

	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	Boat = NewBoat(EntitiesImage)
	local packageSize = 16
	Package = {
		image = EntitiesImage,
		quad = love.graphics.newQuad(0, 2 * packageSize, packageSize, packageSize, EntitiesImage),
		transform = love.math.newTransform(185, -70),
		triggerRadius = 64
	}

	IsCameraPanning = false
	CameraPanSpeed = 0.5
	CameraZoomSpeed = 0.1

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

function love.mousepressed(x, y, button, isTouch, presses)
	if button == 3 then
		IsCameraPanning = not IsCameraPanning
		love.mouse.setRelativeMode(IsCameraPanning)

		if not IsCameraPanning then
			Camera:resetZoom()
		end
	end
end

function love.mousemoved(x, y, dx, dy, isTouch)
	if IsCameraPanning then
		Camera.transform:translate(dx * CameraPanSpeed, dy * CameraPanSpeed)
	end
end

function love.wheelmoved(x, y)
	if IsCameraPanning then
		Camera.zoom = Camera.zoom + y * CameraZoomSpeed
	end
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	Boat:update(dt)


	if not IsCameraPanning then
		local boatX, boatY = Boat.transform:transformPoint(0, 0)
		Camera.transform:setTransformation(boatX, boatY)
	end
end

function love.draw()
	Canvas:renderTo(
		function()
			love.graphics.clear()

			love.graphics.push()
			love.graphics.scale(ScreenScale, ScreenScale)

			love.graphics.draw(BackgroundImage)

			love.graphics.scale(Camera.zoom, Camera.zoom)
			love.graphics.applyTransform(GetWorldToCanvasTransform(Camera))

			Tilemap:draw(Camera)

			Boat:draw()

			love.graphics.push()
			love.graphics.applyTransform(Package.transform)
			love.graphics.draw(Package.image, Package.quad)
			local _, _, width, height = Package.quad:getViewport()
			-- love.graphics.setColor(ColorPalette[2])
			love.graphics.circle("line", width / 2, height / 2, Package.triggerRadius)
			love.graphics.pop()

			love.graphics.pop()
		end
	)
	love.graphics.draw(Canvas, CanvasToScreenTransform)
end
