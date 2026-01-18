require("game/settings")
require("engine/math")
require("engine/tilemap")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	Canvas = love.graphics.newCanvas(CanvasWidth, CanvasHeight)
	Canvas:setFilter("nearest", "nearest")

	ColorPalette = {}
	for hexColor in love.filesystem.lines("assets/art/look-of-horror.hex") do
		table.insert(ColorPalette, hexColor)
	end

	Tileset = NewTileset("assets/art/tileset.png", 32)
	Tilemap = NewTilemap("assets/art/map.csv")

	local windowWidth, windowHeight = love.graphics.getDimensions()
	CanvasScale = math.min(windowWidth / CanvasWidth, windowHeight / CanvasHeight)
	CanvasTransform = love.math.newTransform(0, 0, 0, CanvasScale, CanvasScale)

	WorldTransform = love.math.newTransform(windowWidth / 2, windowHeight / 2)

	BackgroundImage = love.graphics.newImage("assets/art/background.png")
	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	local entitiesImageWidth = EntitiesImage:getWidth()
	local entitiesImageHeight = EntitiesImage:getHeight()

	BackgroundQuad = love.graphics.newQuad(0, 0, CanvasWidth, CanvasHeight, entitiesImageWidth, entitiesImageHeight)

	local boatWidth, boatHeight = 32, 32
	BoatQuad = love.graphics.newQuad(0, 0, boatWidth, boatHeight, entitiesImageWidth, entitiesImageHeight)
	BoatTransform = love.math.newTransform(0, 0, 0, 1, 1)
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
end

function love.draw()
	love.graphics.push()
	love.graphics.applyTransform(WorldTransform)
	love.graphics.applyTransform(CanvasTransform)

	local _, _, backgroundWidth, backgroundHeight = BackgroundQuad:getViewport()
	love.graphics.draw(BackgroundImage, BackgroundQuad, 0, 0, 0, 1, 1, backgroundWidth / 2, backgroundHeight / 2)

	love.graphics.pop()


	love.graphics.push()
	love.graphics.applyTransform(CanvasTransform)
	DrawTilemap(Tilemap, Tileset)
	love.graphics.pop()


	love.graphics.push()
	love.graphics.applyTransform(WorldTransform)
	love.graphics.applyTransform(CanvasTransform)
	love.graphics.applyTransform(BoatTransform)

	local _, _, boatWidth, boatHeight = BoatQuad:getViewport()
	love.graphics.draw(EntitiesImage, BoatQuad, 0, 0, 0, 1, 1, boatWidth / 2, boatHeight / 2)

	love.graphics.pop()
end
