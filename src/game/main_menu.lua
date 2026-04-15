local mainMenu = {}

local draw = require("engine/draw")
local collision = require("engine/collision")

local backgroundImage
local playButton

function mainMenu.load()
	backgroundImage = love.graphics.newImage("assets/art/main_menu.png")

	local buttonImage = love.graphics.newImage("assets/art/button.png")
	local buttonColliderWidth, buttonColliderHeight = buttonImage:getDimensions()
	playButton = {
		shouldDraw = true,
		image = buttonImage,
		transform = love.math.newTransform(75, 175),
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
		print("button clicked")
	else
		print("button not clicked")
	end
end

function mainMenu.mousemoved(x, y, dx, dy, isTouch)
	if collision.hitTest(x, y, playButton.collider, { playButton.transform:transformPoint(0, 0) }) then
		print("on button")
	else
		print("off button")
	end
end

function mainMenu.wheelmoved(x, y)
end

function mainMenu.update(dt)
end

function mainMenu.draw()
	love.graphics.draw(backgroundImage)
	draw.draw(playButton)
	-- love.graphics.draw(buttonImage, 75, 250)
end

return mainMenu
