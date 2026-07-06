local pauseMenu = {}

local settings = require("engine/settings")
local scene = require("engine/scene")
local draw = require("engine/draw")
local collision = require("engine/collision")
local animation = require("engine/animation")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local uiTransform

local menu

local resumeButton
local exitButton


function pauseMenu.load()
	uiTransform = love.math.newTransform(settings.canvasPixelWidth / 2, settings.canvasPixelHeight / 2)
	local menuImage = love.graphics.newImage("assets/art/pause_menu.png")
	local width, height = menuImage:getDimensions()
	local xOffset, yOffset = -width / 2, -height / 2
	menu = {
		drawComponent = draw.new(menuImage, nil, xOffset, yOffset),
		transform = love.math.newTransform(settings.canvasPixelWidth / 2, settings.canvasPixelHeight / 2)
	}

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local numButtonFrames = 2
	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

	resumeButton = {
		animation = animation.new(buttonImage, numButtonFrames),
		transform = love.math.newTransform(settings.canvasPixelWidth / 2, 175),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
	-- resumeButton.animation.xOffset = -buttonImageWidth / 2
	-- resumeButton.animation.yOffset = -buttonImageHeight / 2
	resumeButton.animation.centered = false

	exitButton = {
		animation = animation.new(buttonImage, numButtonFrames),
		transform = love.math.newTransform(settings.canvasPixelWidth / 2, 250),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
	-- exitButton.animation.xOffset = -buttonImageWidth / 2
	-- exitButton.animation.yOffset = -buttonImageHeight / 2
	exitButton.animation.centered = false
end

function pauseMenu.unload()
end

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
	love.graphics.push()
	-- love.graphics.applyTransform(uiTransform)

	love.graphics.setShader()
	draw.draw(menu.drawComponent, menu.transform)

	draw.draw(resumeButton.animation, resumeButton.transform)
	love.graphics.print("play", resumeButton.transform:transformPoint(10, 15))
	draw.draw(exitButton.animation, exitButton.transform)
	love.graphics.print("exit", exitButton.transform:transformPoint(10, 15))

	love.graphics.pop()
end

return pauseMenu
