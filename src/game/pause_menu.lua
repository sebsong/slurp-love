local pauseMenu = {}

local scene = require("engine/scene")
local draw = require("engine/draw")
local collision = require("engine/collision")
local animation = require("engine/animation")
local ui = require("engine/ui")

local font = require("game/font")

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

function pauseMenu.open()
	scene.start(scene.scenes.pauseMenu)
end

function pauseMenu.close()
	isOpen = false
	animation.play(menu.drawComponent, true, function() shouldStop = true end)
end

function pauseMenu.toggle()
	local gameScene = scene.scenes.game
	local pauseScene = scene.scenes.pauseMenu
	if not pauseScene.isActive then
		pauseMenu.open()
		scene.pause(gameScene)
	else
		pauseMenu.close()
		scene.resume(gameScene) -- TODO: need to have some ref counter for how many things pausing the game
	end
end

function pauseMenu.load()
	isOpen = false
	shouldStop = false
	local menuImage = love.graphics.newImage("assets/art/pause_menu.png")
	-- local menuDrawComponent = draw.new(menuImage)
	local menuDrawComponent = animation.new(menuImage, 6, 0.15)
	animation.play(menuDrawComponent, false, function() isOpen = true end)
	menu = {
		drawComponent = menuDrawComponent,
		transform = ui.newAlignedTransform(menuDrawComponent.width, menuDrawComponent.height, ui.align.CENTER, ui.align.CENTER)
	}

	titleTextTransform = ui.newAlignedTransform(menuDrawComponent.width, font.large:getHeight(), ui.align.CENTER, ui.align.CENTER, 0, -75)

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
	resumeTextTransform = ui.newAlignedTransform(resumeDrawComponent.width, font.medium:getHeight(), ui.align.CENTER, ui.align.CENTER)

	local mainMenuDrawComponent = animation.new(buttonImage, numButtonFrames)
	local yOffset = mainMenuDrawComponent.height * 1.1
	mainMenuButton = {
		drawComponent = mainMenuDrawComponent,
		transform = ui.newAlignedTransform(mainMenuDrawComponent.width, mainMenuDrawComponent.height, ui.align.CENTER, ui.align.CENTER, 0, yOffset),
		collider = { width = buttonColliderWidth, height = buttonColliderHeight },
		isPressed = false,
		isHovered = false
	}
	mainMenuTextTransform = ui.newAlignedTransform(mainMenuDrawComponent.width, font.medium:getHeight(), ui.align.CENTER, ui.align.CENTER, 0, yOffset)
end

function pauseMenu.unload()
end

function pauseMenu.keypressed(key, scancode, isRepeat)
end

function pauseMenu.mousepressed(x, y, button, isTouch, presses)
	if collision.hitTest(x, y, resumeButton.collider, resumeButton.transform) then
		pauseMenu.toggle()
	end

	if collision.hitTest(x, y, mainMenuButton.collider, mainMenuButton.transform) then
		scene.transition(scene.scenes.mainMenu)
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
	animation.update(menu.drawComponent, dt)

	if shouldStop then
		scene.stop(scene.scenes.pauseMenu)
	end
end

function pauseMenu.draw()
	love.graphics.push()

	love.graphics.setShader()
	draw.draw(menu.drawComponent, menu.transform)

	if not isOpen then
		love.graphics.pop()
		return
	end

	love.graphics.setFont(font.large)
	love.graphics.printf("paused", titleTextTransform, menu.drawComponent.width, "center")

	love.graphics.setFont(font.medium)
	draw.draw(resumeButton.drawComponent, resumeButton.transform)
	love.graphics.printf("resume", resumeTextTransform, resumeButton.drawComponent.width, "center")
	draw.draw(mainMenuButton.drawComponent, mainMenuButton.transform)
	love.graphics.printf("main menu", mainMenuTextTransform, mainMenuButton.drawComponent.width, "center")

	love.graphics.pop()
end

return pauseMenu
