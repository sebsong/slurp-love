local PauseMenu = {}

local Scene = require("engine/scene")
local Sprite = require("engine/sprite")
local Collision = require("engine/collision")
local Animation = require("engine/animation")
local Ui = require("engine/ui")

local Font = require("game/font")

local DEFAULT_FRAME = 1
local HOVER_FRAME = 2

local isOpen
local shouldStop

local menu

local resumeButton
local mainMenuButton

local titleTextTransform
local resumeTextTransform
local mainMenuTextTransform

function PauseMenu.open()
	Scene.start(Scene.scenes.pauseMenu)
end

function PauseMenu.close()
	isOpen = false
	Animation.play(menu.drawComponent, true, function() shouldStop = true end)
end

function PauseMenu.toggle()
	local gameScene = Scene.scenes.game
	local pauseScene = Scene.scenes.pauseMenu
	if not pauseScene.isActive then
		PauseMenu.open()
		Scene.pause(gameScene)
	else
		PauseMenu.close()
		Scene.resume(gameScene) -- TODO: need to have some ref counter for how many things pausing the game
	end
end

function PauseMenu.load()
	isOpen = false
	shouldStop = false
	local menuImage = love.graphics.newImage("assets/art/pause_menu.png")
	-- local menuDrawComponent = Sprite.new(menuImage)
	local menuDrawComponent = Animation.new(menuImage, 6, 0.15)
	Animation.play(menuDrawComponent, false, function() isOpen = true end)
	menu = {
		drawComponent = menuDrawComponent,
		transform = Ui.newAlignedTransform(menuDrawComponent.width, menuDrawComponent.height, Ui.align.CENTER, Ui.align.CENTER)
	}

	titleTextTransform = Ui.newAlignedTransform(menuDrawComponent.width, Font.large:getHeight(), Ui.align.CENTER, Ui.align.CENTER, 0, -75)

	local buttonImage = love.graphics.newImage("assets/art/button.png")

	local numButtonFrames = 2
	local buttonImageWidth, buttonImageHeight = buttonImage:getDimensions()
	local buttonColliderWidth, buttonColliderHeight = buttonImageWidth / numButtonFrames, buttonImageHeight

	local resumeDrawComponent = Animation.new(buttonImage, numButtonFrames)
	resumeButton = {
		drawComponent = resumeDrawComponent,
		transform = Ui.newAlignedTransform(resumeDrawComponent.width, resumeDrawComponent.height, Ui.align.CENTER, Ui.align.CENTER),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
	resumeTextTransform = Ui.newAlignedTransform(resumeDrawComponent.width, Font.medium:getHeight(), Ui.align.CENTER, Ui.align.CENTER)

	local mainMenuDrawComponent = Animation.new(buttonImage, numButtonFrames)
	local yOffset = mainMenuDrawComponent.height * 1.1
	mainMenuButton = {
		drawComponent = mainMenuDrawComponent,
		transform = Ui.newAlignedTransform(mainMenuDrawComponent.width, mainMenuDrawComponent.height, Ui.align.CENTER, Ui.align.CENTER, 0, yOffset),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
	mainMenuTextTransform = Ui.newAlignedTransform(mainMenuDrawComponent.width, Font.medium:getHeight(), Ui.align.CENTER, Ui.align.CENTER, 0, yOffset)
end

function PauseMenu.unload()
end

function PauseMenu.onPause()
end

function PauseMenu.onResume()
end

function PauseMenu.keypressed(key, scancode, isRepeat)
end

function PauseMenu.mousepressed(x, y, button, isTouch, presses)
	if Collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
		PauseMenu.toggle()
	end

	if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		Scene.transition(Scene.scenes.mainMenu)
	end
end

function PauseMenu.mousemoved(x, y, dx, dy, isTouch)
	if Collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
		resumeButton.drawComponent.currentFrame = HOVER_FRAME
	else
		resumeButton.drawComponent.currentFrame = DEFAULT_FRAME
	end

	if Collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		mainMenuButton.drawComponent.currentFrame = HOVER_FRAME
	else
		mainMenuButton.drawComponent.currentFrame = DEFAULT_FRAME
	end
end

function PauseMenu.wheelmoved(x, y)
end

function PauseMenu.update(dt)
	Animation.update(menu.drawComponent, dt)

	if shouldStop then
		Scene.stop(Scene.scenes.pauseMenu)
	end
end

function PauseMenu.draw()
	love.graphics.push()

	love.graphics.setShader()
	Sprite.draw(menu.drawComponent, menu.transform)

	if not isOpen then
		love.graphics.pop()
		return
	end

	love.graphics.setFont(Font.large)
	love.graphics.printf("paused", titleTextTransform, menu.drawComponent.width, "center")

	love.graphics.setFont(Font.medium)
	Sprite.draw(resumeButton.drawComponent, resumeButton.transform)
	love.graphics.printf("resume", resumeTextTransform, resumeButton.drawComponent.width, "center")
	Sprite.draw(mainMenuButton.drawComponent, mainMenuButton.transform)
	love.graphics.printf("main menu", mainMenuTextTransform, mainMenuButton.drawComponent.width, "center")

	love.graphics.pop()
end

return PauseMenu
