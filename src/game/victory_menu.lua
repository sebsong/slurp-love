local victoryMenu = {}

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

local victoryTextTransform
local mainMenuButton

function victoryMenu.load()
	local menuImage = love.graphics.newImage("assets/art/victory_menu.png")
	local menuDrawComponent = draw.new(menuImage)
	menu = {
		drawComponent = menuDrawComponent,
		transform = ui.newAlignedTransform(menuDrawComponent.width, menuDrawComponent.height, ui.align.CENTER, ui.align.CENTER)
	}

	victoryTextTransform = love.math.newTransform(0, 50)

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local numButtonFrames = 2
	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

	local mainMenuDrawComponent = animation.new(buttonImage, numButtonFrames)
	mainMenuButton = {
		drawComponent = mainMenuDrawComponent,
		transform = ui.newAlignedTransform(mainMenuDrawComponent.width, mainMenuDrawComponent.height, ui.align.CENTER, ui.align.CENTER, 0, mainMenuDrawComponent.height * 1.1),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
end

function victoryMenu.unload()
end

function victoryMenu.keypressed(key, scancode, isRepeat)
end

function victoryMenu.mousepressed(x, y, button, isTouch, presses)
	if collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		scene.transition(scene.scenes.mainMenu)
	end
end

function victoryMenu.mousemoved(x, y, dx, dy, isTouch)
	if collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		mainMenuButton.drawComponent.currentFrame = HOVER_FRAME
	else
		mainMenuButton.drawComponent.currentFrame = DEFAULT_FRAME
	end
end

function victoryMenu.wheelmoved(x, y)
end

function victoryMenu.update(dt)
end

function victoryMenu.draw()
	love.graphics.push()

	love.graphics.setShader()
	-- draw.draw(menu.drawComponent, menu.transform)
	love.graphics.setFont(font.default)
	love.graphics.printf("you're hired", victoryTextTransform, settings.canvasPixelWidth, "center")

	love.graphics.setFont(font.small)
	draw.draw(mainMenuButton.drawComponent, mainMenuButton.transform)
	love.graphics.print("main menu", mainMenuButton.transform:transformPoint(10, 15))

	love.graphics.pop()
end

return victoryMenu
