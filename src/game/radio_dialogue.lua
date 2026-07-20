local radioDialogue = {}

local draw = require("engine/draw")
local ui = require("engine/ui")

local font = require("game/font")
local gameUi = require("game/ui")

local DEFAULT_CHARACTERS_PER_SECOND = 20
local FAST_FORWARD_MULTIPLIER = 10

local dialogueBox
local textWidth
local textHeight
local textTransform

local fullText
local currentText
local numCharactersToShow
local charactersPerSecond
local isFastForwarding
local isFinished

local function reset()
	currentText = ""
	numCharactersToShow = 0
	charactersPerSecond = DEFAULT_CHARACTERS_PER_SECOND
	isFastForwarding = false
	isFinished = false
end

local function onTextFinish()
	isFinished = true
	isFastForwarding = false
end

function radioDialogue.setText(text)
	-- pre-wrap text to avoid words wrapping as they're revealed
	local _, lines = font.small:getWrap(text:lower(), textWidth)
	fullText = table.concat(lines, '\n')
	reset()
end

function radioDialogue.load()
	local dialogueBoxImage = love.graphics.newImage("assets/art/dialogue_box.png")
	local dialogueBoxDrawComponent = draw.new(dialogueBoxImage)
	dialogueBox = {
		drawComponent = dialogueBoxDrawComponent,
		transform = ui.newAlignedTransform(dialogueBoxDrawComponent.width, dialogueBoxDrawComponent.height, ui.align.CENTER, ui.align.BOTTOM, 0, 10)
	}

	textWidth = dialogueBox.drawComponent.width * 3 / 4
	textHeight = dialogueBox.drawComponent.height - gameUi.PADDING * 2
	local xPadding = (dialogueBox.drawComponent.width - textWidth) / 3
	local yPadding = gameUi.PADDING * 2.5
	textTransform = ui.newAlignedTransform(textWidth, textHeight, ui.align.CENTER, ui.align.BOTTOM, xPadding, yPadding)

	radioDialogue.setText("According to all known laws of aviation, there is no way a bee should be able to fly. Its wings are too small to get its fat little body off the ground.")
end

function radioDialogue.unload()
end

function radioDialogue.keypressed(key, scancode, isRepeat)
	if key == "space" then
		isFastForwarding = true
	end
end

function radioDialogue.mousepressed(x, y, button, isTouch, presses)
end

function radioDialogue.mousemoved(x, y, dx, dy, isTouch)
end

function radioDialogue.wheelmoved(x, y)
end

function radioDialogue.update(dt)
	if isFinished then
		return
	end

	local numAdditionalCharacters = charactersPerSecond * dt
	if isFastForwarding then
		numAdditionalCharacters = numAdditionalCharacters * FAST_FORWARD_MULTIPLIER
	end
	numCharactersToShow = numCharactersToShow + numAdditionalCharacters
	currentText = string.sub(fullText, 1, numCharactersToShow)

	if #currentText == #fullText then
		onTextFinish()
	end
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
