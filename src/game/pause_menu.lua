local pauseMenu = {}

local scene = require("engine/scene")
local draw = require("engine/draw")
local collision = require("engine/collision")
local animation = require("engine/animation")
local ui = require("engine/ui")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local menu

local resumeButton
local mainMenuButton

function pauseMenu.load()
	local menuImage = love.graphics.newImage("assets/art/pause_menu.png")
	local menuDrawComponent = draw.new(menuImage)
	menu = {
		drawComponent = menuDrawComponent,
		transform = ui.newAlignedTransform(menuDrawComponent.width, menuDrawComponent.height, ui.align.CENTER, ui.align.CENTER)
	}

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local numButtonFrames = 2
	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

	local resumeDrawComponent = animation.new(buttonImage, numButtonFrames)
	resumeButton = {
		drawComponent = resumeDrawComponent,
		transform = ui.newAlignedTransform(resumeDrawComponent.width, resumeDrawComponent.height, ui.align.CENTER, ui.align.CENTER),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}

	local mainMenuDrawComponent = animation.new(buttonImage, numButtonFrames)
	mainMenuButton = {
		drawComponent = mainMenuDrawComponent,
		transform = ui.newAlignedTransform(mainMenuDrawComponent.width, mainMenuDrawComponent.height, ui.align.CENTER, ui.align.CENTER, 0, mainMenuDrawComponent.height * 1.1),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
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

	if collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		scene.stop(scene.scenes.pauseMenu)
		scene.stop(scene.scenes.game)
		scene.start(scene.scenes.mainMenu)
	end
end

function pauseMenu.mousemoved(x, y, dx, dy, isTouch)
	if collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
		resumeButton.drawComponent.currentFrame = HOVER_FRAME
	else
		resumeButton.drawComponent.currentFrame = DEFAULT_FRAME
	end

	if collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		mainMenuButton.drawComponent.currentFrame = HOVER_FRAME
	else
		mainMenuButton.drawComponent.currentFrame = DEFAULT_FRAME
	end
end

function pauseMenu.wheelmoved(x, y)
end

function pauseMenu.update(dt)
end

function pauseMenu.draw()
	love.graphics.push()

	love.graphics.setShader()
	draw.draw(menu.drawComponent, menu.transform)

	draw.draw(resumeButton.drawComponent, resumeButton.transform)
	love.graphics.print("play", resumeButton.transform:transformPoint(10, 15))
	draw.draw(mainMenuButton.drawComponent, mainMenuButton.transform)
	love.graphics.print("main menu", mainMenuButton.transform:transformPoint(10, 15))

	love.graphics.pop()
end

return pauseMenu
