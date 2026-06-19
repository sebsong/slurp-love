local pauseMenu = {}

local scene = require("engine/scene")
local draw = require("engine/draw")
local collision = require("engine/collision")
local animation = require("engine/animation")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local menu_image

local resumeButton
local exitButton

function pauseMenu.toggle()
	local gameScene = scene.scenes.game
	local pauseScene = scene.scenes.pauseMenu
	if not gameScene.isPaused then
		scene.start(pauseScene)
		scene.pause(gameScene)
	else
		scene.stop(pauseScene)
		scene.resume(gameScene)
	end
end

function pauseMenu.load()
	menu_image = love.graphics.newImage("assets/art/pause_menu.png")

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local numButtonFrames = 2
	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

	resumeButton = {
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

function pauseMenu.unload()
end

function pauseMenu.keypressed(key, scancode, isRepeat)
end

function pauseMenu.mousepressed(x, y, button, isTouch, presses)
	if collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
		pauseMenu.toggle()
	end

	if collision.hitTest(x, y, exitButton.collider, exitButton.transform) then
		love.event.quit()
	end
end

function pauseMenu.mousemoved(x, y, dx, dy, isTouch)
	if collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
		resumeButton.animation.currentFrame = HOVER_FRAME
	else
		resumeButton.animation.currentFrame = DEFAULT_FRAME
	end

	if collision.hitTest(x, y, exitButton.collider, exitButton.transform) then
		exitButton.animation.currentFrame = HOVER_FRAME
	else
		exitButton.animation.currentFrame = DEFAULT_FRAME
	end
end

function pauseMenu.wheelmoved(x, y)
end

function pauseMenu.update(dt)
end

function pauseMenu.draw()
	love.graphics.setShader()
	love.graphics.draw(menu_image)

	draw.draw(resumeButton.animation, resumeButton.transform)
	love.graphics.print("play", resumeButton.transform:transformPoint(10, 15))
	draw.draw(exitButton.animation, exitButton.transform)
	love.graphics.print("exit", exitButton.transform:transformPoint(10, 15))
end

return pauseMenu
