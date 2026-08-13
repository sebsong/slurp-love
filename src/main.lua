-- make sure to load debug utils before anything else
require("engine.debug")

local Canvas = require("engine.canvas")
local SceneManager = require("engine.scene_manager")

local DaySelector = require("game.scenes.day_selector")
local DayTracker = require("game.scenes.day_tracker")
local Debug = require("game.scenes.debug")
local Font = require("game.font")
local Game = require("game.scenes.game")
local GameOverMenu = require("game.scenes.game_over_menu")
local Global = require("game.scenes.global")
local MailDialogue = require("game.scenes.mail_dialogue")
local MainMenu = require("game.scenes.main_menu")
local Map = require("game.scenes.map")
local PackageDetail = require("game.scenes.package_detail")
local PauseMenu = require("game.scenes.pause_menu")
local VictoryMenu = require("game.scenes.victory_menu")

---@diagnostic disable-next-line: duplicate-set-field
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setPointSize(8)
    love.graphics.setLineWidth(0.1)
    love.graphics.setBackgroundColor(0, 0, 0)
    Canvas.load()
    Font.load()

    SceneManager.register("global", Global, true)
    SceneManager.register("debug", Debug, true)

    SceneManager.register("mainMenu", MainMenu)
    SceneManager.register("daySelector", DaySelector)
    SceneManager.register("dayTracker", DayTracker)
    SceneManager.register("game", Game)
    SceneManager.register("mailDialogue", MailDialogue)
    SceneManager.register("packageDetail", PackageDetail)
    SceneManager.register("map", Map)
    SceneManager.register("pauseMenu", PauseMenu)
    SceneManager.register("gameOverMenu", GameOverMenu)
    SceneManager.register("victoryMenu", VictoryMenu)

    SceneManager.scenes.global:start()
    SceneManager.scenes.debug:start()
    SceneManager.scenes.mainMenu:start()
    -- SceneManager.scenes.game:start()
    -- SceneManager.scenes.packageDetail:start()
end

---@diagnostic disable-next-line: duplicate-set-field
function love.keypressed(key, scancode, isRepeat)
    SceneManager.keypressed(key, scancode, isRepeat)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.mousepressed(x, y, button, isTouch, presses)
    x, y = Canvas.screenToCanvasTransform:transformPoint(x, y)
    SceneManager.mousepressed(x, y, button, isTouch, presses)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.mousemoved(x, y, dx, dy, isTouch)
    x, y = Canvas.screenToCanvasTransform:transformPoint(x, y)
    SceneManager.mousemoved(x, y, dx, dy, isTouch)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.wheelmoved(x, y)
    SceneManager.wheelmoved(x, y)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.update(dt)
    SceneManager.update(dt)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.draw()
    Canvas.draw(SceneManager.draw)
end
