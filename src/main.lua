require("game/settings")
require("engine/math")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	Canvas = love.graphics.newCanvas(CanvasWidth, CanvasHeight)
	Canvas:setFilter("nearest", "nearest")

	ColorPalette = {}
	for hexColor in love.filesystem.lines("assets/art/look-of-horror.hex") do
		table.insert(ColorPalette, hexColor)
	end

	local windowWidth, windowHeight = love.graphics.getDimensions()
	CanvasScale = math.min(windowWidth / CanvasWidth, windowHeight / CanvasHeight)

	WorldTransform = love.math.newTransform(windowWidth / 2, windowHeight / 2, 0, CanvasScale, CanvasScale)

	World = love.physics.newWorld(0, 0)
	BoatBody = love.physics.newBody(World, 0, 0, "dynamic")

	BackgroundImage = love.graphics.newImage("assets/art/background.png")
	EntitiesImage = love.graphics.newImage("assets/art/entities.png")
	local entitiesImageWidth = EntitiesImage:getWidth()
	local entitiesImageHeight = EntitiesImage:getHeight()

	BackgroundQuad = love.graphics.newQuad(0, 0, CanvasWidth, CanvasHeight, entitiesImageWidth, entitiesImageHeight)

	local boatWidth, boatHeight = 32, 32
	BoatQuad = love.graphics.newQuad(0, 0, boatWidth, boatHeight, entitiesImageWidth, entitiesImageHeight)
	BoatTransform = love.math.newTransform(0, 0, 0, 1, 1)
	Speed = 75
	RotSpeed = PI / 4

	Bgm = love.audio.newSource("assets/sound/bgm.ogg", "stream")
	Bgm:setVolume(0.3)
	Bgm:setLooping(true)
	Bgm:play()

	love.graphics.setPointSize(5)
end

function love.update(dt)
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end

	if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
		BoatTransform:translate(0, -Speed * dt)
	end
	if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
		BoatTransform:translate(0, 0.25 * Speed * dt)
	end
	if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
		BoatTransform:rotate(-RotSpeed * dt)
	end
	if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
		BoatTransform:rotate(RotSpeed * dt)
	end
end

function love.draw()
	love.graphics.push()

	love.graphics.applyTransform(WorldTransform)

	local _, _, backgroundWidth, backgroundHeight = BackgroundQuad:getViewport()
	love.graphics.draw(BackgroundImage, BackgroundQuad, 0, 0, 0, 1, 1, backgroundWidth / 2, backgroundHeight / 2)

	love.graphics.applyTransform(BoatTransform)
	local _, _, boatWidth, boatHeight = BoatQuad:getViewport()
	love.graphics.draw(EntitiesImage, BoatQuad, 0, 0, 0, 1, 1, boatWidth / 2, boatHeight / 2)

	love.graphics.pop()

	local x, y = WorldTransform:transformPoint(BoatTransform:inverseTransformPoint(0, 1))
	print(x, y)
	love.graphics.points(x, y)
end
