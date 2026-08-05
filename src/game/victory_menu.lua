local VictoryMenu = {}

local Align = require("engine.ui.align")
local Button = require("engine.ui.button")
local Scene = require("engine.scene")
local Settings = require("engine.settings")
local Sprite = require("engine.sprite")

local Font = require("game.font")

local menu

local victoryTextTransform
local mainMenuButton

function VictoryMenu.load()
    local menuImage = love.graphics.newImage("assets/art/victory_menu.png")
    local menuSprite = Sprite.new(menuImage)
    menu = {
        sprite = menuSprite,
        transform = Align.screenAlignedTransform(menuSprite.width, menuSprite.height, Align.CENTER, Align.CENTER),
    }

    victoryTextTransform = love.math.newTransform(0, 50)

    local buttonImage = love.graphics.newImage("assets/art/button.png")

    local numButtonFrames = 2

    local mainMenuSprite = Sprite.newAnimated(buttonImage, numButtonFrames)
    local mainMenuTransform = Align.screenAlignedTransform(
        mainMenuSprite.width,
        mainMenuSprite.height,
        Align.CENTER,
        Align.CENTER,
        0,
        mainMenuSprite.height * 1.1
    )
    mainMenuButton = Button.new(mainMenuSprite, mainMenuTransform, Font.medium, "main menu", nil, function(_button)
        Scene.transition(Scene.scenes.mainMenu)
    end)
end

function VictoryMenu.unload() end

function VictoryMenu.onPause() end

function VictoryMenu.onResume() end

function VictoryMenu.keypressed(key, scancode, isRepeat) end

function VictoryMenu.mousepressed(x, y, button, isTouch, presses)
    mainMenuButton:mousepressed(x, y, button, isTouch, presses)
end

function VictoryMenu.mousemoved(x, y, dx, dy, isTouch)
    mainMenuButton:mousemoved(x, y, dx, dy, isTouch)
end

function VictoryMenu.wheelmoved(x, y) end

function VictoryMenu.update(dt) end

function VictoryMenu.draw()
    love.graphics.push()

    love.graphics.setShader()
    -- Sprite.draw(menu.sprite, menu.transform)
    love.graphics.setFont(Font.large)
    love.graphics.printf("you're hired", victoryTextTransform, Settings.canvasPixelWidth, "center")

    mainMenuButton:draw()

    love.graphics.pop()
end

return VictoryMenu
