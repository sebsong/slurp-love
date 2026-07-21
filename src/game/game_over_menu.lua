local gameOverMenu = {}

local scene = require("engine/scene")
local draw = require("engine/draw")
local collision = require("engine/collision")
local animation = require("engine/animation")
local ui = require("engine/ui")
local settings = require("engine/settings")

local font = require("game/font")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local menu

local gameOverTextTransform

local restartButton
local mainMenuButton

function gameOverMenu.load()
	local menuImage = love.graphics.newImage("assets/art/game_over_menu.png")
	local menuDrawComponent = draw.new(menuImage)
	menu = {
		drawComponent = menuDrawComponent,
		transform = ui.newAlignedTransform(menuDrawComponent.width, menuDrawComponent.height, ui.align.CENTER, ui.align.CENTER)
	}

	gameOverTextTransform = love.math.newTransform(0, 50)

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local numButtonFrames = 2
	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

	local restartDrawComponent = animation.new(buttonImage, numButtonFrames)
	restartButton = {
		drawComponent = restartDrawComponent,
		transform = ui.newAlignedTransform(restartDrawComponent.width, restartDrawComponent.height, ui.align.CENTER, ui.align.CENTER),
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

function gameOverMenu.unload()
end

function gameOverMenu.keypressed(key, scancode, isRepeat)
end

function gameOverMenu.mousepressed(x, y, button, isTouch, presses)
	if collision.hitTest(x, y, restartButton.collider, restartButton.transform) then
		scene.stop(scene.scenes.gameOverMenu)
		scene.restart(scene.scenes.game)
	end

	if collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		scene.transition(scene.scenes.mainMenu)
	end
end

function gameOverMenu.mousemoved(x, y, dx, dy, isTouch)
	if collision.hitTest(x, y, restartButton.collider, restartButton.transform) then
		restartButton.drawComponent.currentFrame = HOVER_FRAME
	else
		restartButton.drawComponent.currentFrame = DEFAULT_FRAME
	end

	if collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		mainMenuButton.drawComponent.currentFrame = HOVER_FRAME
	else
		mainMenuButton.drawComponent.currentFrame = DEFAULT_FRAME
	end
end

function gameOverMenu.wheelmoved(x, y)
end

function gameOverMenu.update(dt)
end

function gameOverMenu.draw()
	love.graphics.push()

	love.graphics.setShader()
	-- draw.draw(menu.drawComponent, menu.transform)
	love.graphics.setFont(font.default)
	love.graphics.printf("you're fired", gameOverTextTransform, settings.canvasPixelWidth, "center")

	love.graphics.setFont(font.small)
	draw.draw(restartButton.drawComponent, restartButton.transform)
	love.graphics.print("restart\n day", restartButton.transform:transformPoint(10, 15))
	draw.draw(mainMenuButton.drawComponent, mainMenuButton.transform)
	love.graphics.print("main menu", mainMenuButton.transform:transformPoint(10, 15))

	love.graphics.pop()
end

return gameOverMenu
