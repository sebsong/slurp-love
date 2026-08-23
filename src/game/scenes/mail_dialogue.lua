local MailDialogue = {}

local Align = require("engine.ui.align")
local Color = require("engine.color")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")
local TextBox = require("engine.ui.text_box")

local Font = require("game.font")
local GameUi = require("game.ui")

local OPEN_STATE = 1
local CLOSED_STATE = 2

local DEFAULT_CHARACTERS_PER_SECOND = 20
local FAST_FORWARD_MULTIPLIER = 10

local isOpen
local shouldStop

local dialogueBox
---@type TextBox
local dialogueTextBox

local dialogueLines = {}
local onDialogueClose

local currentLineIndex
local numCharactersToShow
local charactersPerSecond
local isFastForwarding
local isLineFinished
local isDialogueFinished

local function resetLine()
    dialogueTextBox:setText("")
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
    SceneManager.scenes.mailDialogue:start()
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
    dialogueBox.sprite:transitionAnimationState(CLOSED_STATE)
end

local function setLines(lines)
    for i, line in ipairs(lines) do
        -- pre-wrap text to avoid words wrapping as they're revealed
        local _, textLines = dialogueTextBox.text:getFont():getWrap(line:lower(), dialogueTextBox.width)
        local wrappedLine = table.concat(textLines, "\n")
        dialogueLines[i] = wrappedLine
    end
    resetDialogue()
end

function MailDialogue.load()
    isOpen = false
    shouldStop = false

    local dialogueBoxImage = love.graphics.newImage("assets/art/dialogue_box.png")
    local dialogueBoxSprite = Sprite.newAnimated(dialogueBoxImage, {
        [OPEN_STATE] = {
            numFrames = 12,
            duration = 1.5,
            isLooping = false,
            isReversed = false,
            onFinish = function()
                isOpen = true
            end,
        },
        [CLOSED_STATE] = {
            numFrames = 12,
            duration = 1.5,
            isLooping = false,
            isReversed = true,
            onFinish = function()
                shouldStop = true
            end,
        },
    })
    local dialogueBoxTransform =
        Align.screenAlignedTransform(dialogueBoxSprite.width, dialogueBoxSprite.height, Align.CENTER, Align.BOTTOM)

    dialogueBox = {
        sprite = dialogueBoxSprite,
        transform = dialogueBoxTransform,
    }

    local dialogueTextBoxTransform = dialogueBoxTransform:clone():translate(53 + GameUi.PADDING, 42 + GameUi.PADDING)
    dialogueTextBox = TextBox.new(
        dialogueTextBoxTransform,
        320 - GameUi.PADDING * 2,
        120 - GameUi.PADDING * 2,
        Font.small,
        Color.palette[8],
        "",
        Align.CENTER,
        Align.TOP,
        "left"
    )
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

        SceneManager.scenes.mailDialogue:stop()
    end

    dialogueBox.sprite:update(dt)

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
    local currentLine = string.sub(fullLine, 1, numCharactersToShow)
    dialogueTextBox:setText({ Color.palette[8], currentLine })

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
    dialogueBox.sprite:draw(dialogueBox.transform)

    if not isOpen then
        love.graphics.pop()
        return
    end

    dialogueTextBox:draw()

    love.graphics.pop()
end

return MailDialogue
