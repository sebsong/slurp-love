local mainMenu = {}

local draw = require("engine/draw")
local scene = require("engine/scene")
local collision = require("engine/collision")
local animation = require("engine/animation")

local font = require("game/font")

local backgroundImage
local playButton
local exitButton

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

function mainMenu.load()
	backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local numButtonFrames = 2
	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

	playButton = {
		animation = animation.new(buttonImage, numButtonFrames),
		transform = love.math.newTransform(75, 175),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}

	exitButton = {
		animation = animation.new(buttonImage, numButtonFrames),
		transform = love.math.newTransform(75, 250),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
end

function mainMenu.unload()
end

function mainMenu.keypressed(key, scancode, isRepeat)
end

function mainMenu.mousepressed(x, y, button, isTouch, presses)
	if collision.hitTest(x, y, playButton.collider, playButton.transform) then
		scene.transition(scene.scenes.mainMenu, scene.scenes.dayTracker)
	end

	if collision.hitTest(x, y, exitButton.collider, exitButton.transform) then
		love.event.quit()
	end
end

function mainMenu.mousemoved(x, y, dx, dy, isTouch)
	if collision.hitTest(x, y, playButton.collider, playButton.transform) then
		playButton.animation.currentFrame = HOVER_FRAME
	else
		playButton.animation.currentFrame = DEFAULT_FRAME
	end

	if collision.hitTest(x, y, exitButton.collider, exitButton.transform) then
		exitButton.animation.currentFrame = HOVER_FRAME
	else
		exitButton.animation.currentFrame = DEFAULT_FRAME
	end
end

function mainMenu.wheelmoved(x, y)
end

function mainMenu.update(dt)
end

function mainMenu.draw()
	love.graphics.setFont(font.default)

	love.graphics.draw(backgroundImage)
	draw.draw(playButton.animation, playButton.transform)
	love.graphics.print("play", playButton.transform:transformPoint(10, 15))
	draw.draw(exitButton.animation, exitButton.transform)
	love.graphics.print("exit", exitButton.transform:transformPoint(10, 15))
	love.graphics.print("abcdefghijklm\nnopqrstuvwxyz", 220, 360 - 64 - 16)
end

return mainMenu
