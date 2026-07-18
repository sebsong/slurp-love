local radioDialogue = {}

local scene = require("engine/scene")
local draw = require("engine/draw")
local collision = require("engine/collision")
local animation = require("engine/animation")
local ui = require("engine/ui")

local font = require("game/font")
local gameUi = require("game/ui")

local DEFAULT_CHARACTERS_PER_SECOND = 10

local dialogueBox
local textWidth
local textHeight
local textTransform

local fullText
local currentText
local elapsedSeconds
local charactersPerSecond

local function reset()
	currentText = ""
	elapsedSeconds = 0
	charactersPerSecond = DEFAULT_CHARACTERS_PER_SECOND
end

function radioDialogue.setText(text)
	fullText = text
	reset()
end

function radioDialogue.load()
	radioDialogue.setText(("according to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground."):lower())

	reset()

	local dialogueBoxImage = love.graphics.newImage("assets/art/dialogue_box.png")
	local dialogueBoxDrawComponent = draw.new(dialogueBoxImage)
	dialogueBox = {
		drawComponent = dialogueBoxDrawComponent,
		transform = ui.newAlignedTransform(dialogueBoxDrawComponent.width, dialogueBoxDrawComponent.height, ui.align.CENTER, ui.align.BOTTOM, 0, 10)
	}

	textWidth = dialogueBox.drawComponent.width * 3 / 4
	textHeight = dialogueBox.drawComponent.height - gameUi.PADDING * 2
	local xPadding = (dialogueBox.drawComponent.width - textWidth) / 3
	local yPadding = gameUi.PADDING * 2
	textTransform = ui.newAlignedTransform(textWidth, textHeight, ui.align.CENTER, ui.align.BOTTOM, xPadding, yPadding)
end

function radioDialogue.unload()
end

function radioDialogue.keypressed(key, scancode, isRepeat)
end

function radioDialogue.mousepressed(x, y, button, isTouch, presses)
end

function radioDialogue.mousemoved(x, y, dx, dy, isTouch)
end

function radioDialogue.wheelmoved(x, y)
end

function radioDialogue.update(dt)
	elapsedSeconds = elapsedSeconds + dt

	local numCharactersToShow = elapsedSeconds * charactersPerSecond
	currentText = string.sub(fullText, 1, numCharactersToShow)
end

function radioDialogue.draw()
	love.graphics.push()

	love.graphics.setShader()
	draw.draw(dialogueBox.drawComponent, dialogueBox.transform)

	love.graphics.setFont(font.small)
	love.graphics.printf(currentText, textTransform, textWidth, "left")

	love.graphics.pop()
end

return radioDialogue
