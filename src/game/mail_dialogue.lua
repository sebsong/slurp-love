local MailDialogue = {}

local Animation = require("engine/animation")
local Scene = require("engine/scene")
local Sprite = require("engine/sprite")
local Ui = require("engine/ui/ui")

local Font = require("game/font")

local DEFAULT_CHARACTERS_PER_SECOND = 20
local FAST_FORWARD_MULTIPLIER = 10

local isOpen
local shouldStop

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

function MailDialogue.open(lines, onClose)
    if type(lines) ~= "table" then
        lines = { lines }
    end
    dialogueLines = lines
    onDialogueClose = onClose
    Scene.start(Scene.scenes.mailDialogue)
end

function MailDialogue.next()
    if not isLineFinished then
        if not isFastForwarding then
            isFastForwarding = true
        else
            numCharactersToShow = #dialogueLines[currentLineIndex]
        end
    else
        if not isDialogueFinished then
            currentLineIndex = currentLineIndex + 1
            resetLine()
        else
            MailDialogue.close()
            resetDialogue()
        end
    end
end

function MailDialogue.close()
    isOpen = false
    Animation.play(dialogueBox.sprite.animation, true, function()
        shouldStop = true
    end)
end

local function setLines(lines)
    for i, line in ipairs(lines) do
        -- pre-wrap text to avoid words wrapping as they're revealed
        local _, textLines = Font.medium:getWrap(line:lower(), textWidth)
        local wrappedLine = table.concat(textLines, "\n")
        dialogueLines[i] = wrappedLine
    end
    resetDialogue()
end

function MailDialogue.load()
    isOpen = false
    shouldStop = false

    local dialogueBoxImage = love.graphics.newImage("assets/art/dialogue_box.png")
    -- local dialogueBoxSprite = Sprite.new(dialogueBoxImage)
    local dialogueBoxSprite = Sprite.newAnimated(dialogueBoxImage, 12, 1.5)
    Animation.play(dialogueBoxSprite.animation, false, function()
        isOpen = true
    end)
    dialogueBox = {
        sprite = dialogueBoxSprite,
        transform = Ui.newAlignedTransform(
            dialogueBoxSprite.width,
            dialogueBoxSprite.height,
            Ui.align.CENTER,
            Ui.align.BOTTOM,
            0,
            0
        ),
    }

    textWidth = 475
    textHeight = 100
    local xPadding = 90
    local yPadding = 25
    textTransform = Ui.newAlignedTransform(textWidth, textHeight, Ui.align.CENTER, Ui.align.BOTTOM, xPadding, yPadding)

    setLines(dialogueLines)
end

function MailDialogue.unload() end

function MailDialogue.onPause() end

function MailDialogue.onResume() end

function MailDialogue.keypressed(key, scancode, isRepeat)
    if isOpen and key == "space" then
        MailDialogue.next()
    end
end

function MailDialogue.mousepressed(x, y, button, isTouch, presses) end

function MailDialogue.mousemoved(x, y, dx, dy, isTouch) end

function MailDialogue.wheelmoved(x, y) end

function MailDialogue.update(dt)
    if shouldStop then
        if onDialogueClose then
            onDialogueClose()
        end

        dialogueLines = {}
        onDialogueClose = nil

        Scene.stop(Scene.scenes.mailDialogue)
    end

    Animation.update(dialogueBox.sprite.animation, dt)

    if not isOpen or isDialogueFinished then
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

function MailDialogue.draw()
    love.graphics.push()

    love.graphics.setShader()
    Sprite.draw(dialogueBox.sprite, dialogueBox.transform)

    if not isOpen then
        love.graphics.pop()
        return
    end

    love.graphics.setFont(Font.small)
    love.graphics.printf(currentLine, textTransform, textWidth, "left")

    love.graphics.pop()
end

return MailDialogue
