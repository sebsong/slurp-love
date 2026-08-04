-- make sure to load debug utils before anything else
require("engine/debug")

local Canvas = require("engine/canvas")
local Scene = require("engine/scene")
local Sprite = require("engine/sprite")

local DayTracker = require("game/day_tracker")
local Debug = require("game/debug")
local Font = require("game/font")
local Game = require("game/game")
local GameOverMenu = require("game/game_over_menu")
local Global = require("game/global")
local MailDialogue = require("game/mail_dialogue")
local MainMenu = require("game/main_menu")
local Map = require("game/map")
local PackageDetail = require("game/package_detail")
local PauseMenu = require("game/pause_menu")
local VictoryMenu = require("game/victory_menu")

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    Canvas.load()
    Sprite.load()
    Font.load()

    Scene.register("global", Global, true)
    Scene.register("debug", Debug, true)

    Scene.register("mainMenu", MainMenu)
    Scene.register("dayTracker", DayTracker)
    Scene.register("game", Game)
    Scene.register("mailDialogue", MailDialogue)
    Scene.register("packageDetail", PackageDetail)
    Scene.register("map", Map)
    Scene.register("pauseMenu", PauseMenu)
    Scene.register("gameOverMenu", GameOverMenu)
    Scene.register("victoryMenu", VictoryMenu)

    Scene.start(Scene.scenes.global)
    Scene.start(Scene.scenes.debug)
    Scene.start(Scene.scenes.mainMenu)
    -- Scene.start(Scene.scenes.game)
    -- Scene.start(Scene.scenes.packageDetail)
end

function love.keypressed(key, scancode, isRepeat)
    Scene.keypressed(key, scancode, isRepeat)
end

function love.mousepressed(x, y, button, isTouch, presses)
    x, y = Canvas.screenToCanvasTransform:transformPoint(x, y)
    Scene.mousepressed(x, y, button, isTouch, presses)
end

function love.mousemoved(x, y, dx, dy, isTouch)
    x, y = Canvas.screenToCanvasTransform:transformPoint(x, y)
    Scene.mousemoved(x, y, dx, dy, isTouch)
end

function love.wheelmoved(x, y)
    Scene.wheelmoved(x, y)
end

function love.update(dt)
    Scene.update(dt)
end

function love.draw()
    Canvas.draw(Scene.draw)
end
