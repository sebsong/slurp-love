local mainMenu = {}

local draw = require("engine/draw")
local scene = require("engine/scene")
local collision = require("engine/collision")

local backgroundImage
local playButton
local exitButton

function mainMenu.load()
	backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonDefaultQuad = love.graphics.newQuad(0, 0, buttonImageWidth / 2, buttonImageHeight, buttonImage)
	local buttonHoverQuad = love.graphics.newQuad(buttonImageWidth / 2, 0, buttonImageWidth / 2, buttonImageHeight,
		buttonImage)
	local _, _, buttonColliderWidth, buttonColliderHeight = buttonDefaultQuad:getViewport()
	print(buttonColliderWidth, buttonColliderHeight)
	playButton = {
		shouldDraw = true,
		image = buttonImage,
		quad = buttonDefaultQuad,
		defaultQuad = buttonDefaultQuad,
		hoverQuad = buttonHoverQuad,
		transform = love.math.newTransform(75, 175),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },

		isPressed = false,
		isHovered = false,
	}

	exitButton = {
		shouldDraw = true,
		image = buttonImage,
		quad = buttonDefaultQuad,
		defaultQuad = buttonDefaultQuad,
		hoverQuad = buttonHoverQuad,
		transform = love.math.newTransform(75, 250),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },

		isPressed = false,
		isHovered = false,
	}
end

function mainMenu.unload()
end

function mainMenu.keypressed(key, scancode, isRepeat)
end

function mainMenu.mousepressed(x, y, button, isTouch, presses)
	if collision.hitTest(x, y, playButton.collider, { playButton.transform:transformPoint(0, 0) }) then
		scene.transition(scene.scenes.mainMenu, scene.scenes.game)
	end

	if collision.hitTest(x, y, exitButton.collider, { exitButton.transform:transformPoint(0, 0) }) then
		love.event.quit()
	end
end

function mainMenu.mousemoved(x, y, dx, dy, isTouch)
	if collision.hitTest(x, y, playButton.collider, { playButton.transform:transformPoint(0, 0) }) then
		playButton.quad = playButton.hoverQuad
	else
		playButton.quad = playButton.defaultQuad
	end

	if collision.hitTest(x, y, exitButton.collider, { exitButton.transform:transformPoint(0, 0) }) then
		exitButton.quad = exitButton.hoverQuad
	else
		exitButton.quad = exitButton.defaultQuad
	end
end

function mainMenu.wheelmoved(x, y)
end

function mainMenu.update(dt)
end

function mainMenu.draw()
	love.graphics.draw(backgroundImage)
	draw.draw(playButton)
	draw.draw(exitButton)
	-- love.graphics.draw(buttonImage, 75, 250)
end

return mainMenu
