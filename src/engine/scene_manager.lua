local Scene = require("engine.scene")

---@class SceneManager
---@field scenes table<string, Scene>
local SceneManager = {
    scenes = {}, --TODO: might be better to register these in a separate game scene file
}

---@type Scene[]
local scenesList = {}

---@param sceneName string
---@param scene Scene
---@param isGlobal boolean?
function SceneManager.register(sceneName, scene, isGlobal)
    Scene.init(scene, isGlobal or false)
    table.insert(scenesList, scene)
    SceneManager.scenes[sceneName] = scene
end

---@param scene Scene
function SceneManager.transition(scene)
    for _, s in ipairs(scenesList) do
        if not s.isGlobal and s.isActive then
            s:stop()
        end
    end
    scene:start()
end

local function load(scene)
    assert(not scene.isActive, "can't load an active scene")
    scene.load()
    scene.isActive = true
    scene.shouldLoad = false
end

local function unload(scene)
    assert(scene.isActive, "can't unload an inactive scene")
    scene.unload()
    scene.isActive = false
    scene.shouldUnload = false
end

local function shouldSkipUpdate(scene)
    return not scene.isActive or scene.isPaused
end

local function shouldSkipInput(scene)
    return not scene.isActive or scene.isInputPaused
end

local function shouldSkipDraw(scene)
    return not scene.isActive
end

---@param key love.KeyConstant
---@param scancode love.Scancode
---@param isRepeat boolean
function SceneManager.keypressed(key, scancode, isRepeat)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if scene.keypressed then
            scene.keypressed(key, scancode, isRepeat)
        end

        ::continue::
    end
end

---@param key love.KeyConstant
---@param scancode love.Scancode
function SceneManager.keyreleased(key, scancode)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if scene.keyreleased then
            scene.keyreleased(key, scancode)
        end

        ::continue::
    end
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function SceneManager.mousepressed(x, y, button, isTouch, presses)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if scene.mousepressed then
            scene.mousepressed(x, y, button, isTouch, presses)
        end

        ::continue::
    end
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param isTouch boolean
function SceneManager.mousemoved(x, y, dx, dy, isTouch)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if scene.mousemoved then
            scene.mousemoved(x, y, dx, dy, isTouch)
        end

        ::continue::
    end
end

---@param x number
---@param y number
function SceneManager.wheelmoved(x, y)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if scene.wheelmoved then
            scene.wheelmoved(x, y)
        end

        ::continue::
    end
end

---@param dt number
function SceneManager.update(dt)
    for _, scene in ipairs(scenesList) do
        if scene.shouldUnload then
            unload(scene)
        end
        if scene.shouldLoad then
            load(scene)
        end

        if shouldSkipUpdate(scene) then
            goto continue
        end

        scene.update(dt)

        ::continue::
    end
end

function SceneManager.draw()
    for _, scene in ipairs(scenesList) do
        if shouldSkipDraw(scene) then
            goto continue
        end

        scene.draw()

        ::continue::
    end
end
return SceneManager
