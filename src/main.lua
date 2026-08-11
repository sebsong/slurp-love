-- make sure to load debug utils before anything else
require("engine.debug")

local Canvas = require("engine.canvas")
local SceneManager = require("engine.scene_manager")

local Font = require("game.font")
local Scenes = require("game.scenes.scenes")

---@diagnostic disable-next-line: duplicate-set-field
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setPointSize(8)
    love.graphics.setLineWidth(0.1)
    love.graphics.setBackgroundColor(0, 0, 0)
    Canvas.load()
    Font.load()

    Scenes.register()
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
