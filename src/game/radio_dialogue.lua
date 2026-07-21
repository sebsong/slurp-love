local radioDialogue = {}

local draw = require("engine/draw")
local ui = require("engine/ui")
local scene = require("engine/scene")

local font = require("game/font")
local gameUi = require("game/ui")

local DEFAULT_CHARACTERS_PER_SECOND = 20
local FAST_FORWARD_MULTIPLIER = 10

local dialogueBox
local textWidth
local textHeight
local textTransform

local dialogueLines = {}
local onDialogueClose

local currentLineIndex
local currentLine
local numCharactersToShow
local charactersPerSecond
local isFastForwarding
local isLineFinished
local isDialogueFinished

local function resetLine()
	currentLine = ""
	numCharactersToShow = 0
	isFastForwarding = false
	isLineFinished = false
end

local function resetDialogue()
	resetLine()
	currentLineIndex = 1
	charactersPerSecond = DEFAULT_CHARACTERS_PER_SECOND
	isDialogueFinished = false
end


function radioDialogue.open(lines, onClose)
	if type(lines) ~= "table" then
		lines = { lines }
	end
	dialogueLines = lines
	onDialogueClose = onClose
	scene.start(scene.scenes.radioDialogue)
end

function radioDialogue.next()
	if not isLineFinished then
		isFastForwarding = true
	else
		if not isDialogueFinished then
			currentLineIndex = currentLineIndex + 1
			resetLine()
		else
			radioDialogue.close()
			resetDialogue()
		end
	end
end

function radioDialogue.close()
	scene.stop(scene.scenes.radioDialogue)
	if onDialogueClose then
		onDialogueClose()
	end

	dialogueLines = {}
	onDialogueClose = nil
end

local function setLines(lines)
	for i, line in ipairs(lines) do
		-- pre-wrap text to avoid words wrapping as they're revealed
		local _, textLines = font.small:getWrap(line:lower(), textWidth)
		local wrappedLine = table.concat(textLines, '\n')
		dialogueLines[i] = wrappedLine
	end
	resetDialogue()
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

	setLines(dialogueLines)
end

function radioDialogue.unload()
end

function radioDialogue.keypressed(key, scancode, isRepeat)
	if key == "space" then
		radioDialogue.next()
	end
end

function radioDialogue.mousepressed(x, y, button, isTouch, presses)
end

function radioDialogue.mousemoved(x, y, dx, dy, isTouch)
end

function radioDialogue.wheelmoved(x, y)
end

function radioDialogue.update(dt)
	if isDialogueFinished then
		return
	end

	local fullLine = dialogueLines[currentLineIndex]
	if not fullLine then
		return
	end

	local numAdditionalCharacters = charactersPerSecond * dt
	if isFastForwarding then
		numAdditionalCharacters = numAdditionalCharacters * FAST_FORWARD_MULTIPLIER
	end
	numCharactersToShow = numCharactersToShow + numAdditionalCharacters
	currentLine = string.sub(fullLine, 1, numCharactersToShow)

	if not isLineFinished and #currentLine == #fullLine then
		isLineFinished = true
		if currentLineIndex >= #dialogueLines then
			isDialogueFinished = true
		end
	end
end

function radioDialogue.draw()
	love.graphics.push()

	love.graphics.setShader()
	draw.draw(dialogueBox.drawComponent, dialogueBox.transform)

	love.graphics.setFont(font.small)
	love.graphics.printf(currentLine, textTransform, textWidth, "left")

	love.graphics.pop()
end

return radioDialogue
