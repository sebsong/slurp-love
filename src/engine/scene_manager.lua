local Scene = require("engine.scene")

---@class SceneManager
---@field scenes table<string, Scene>
local SceneManager = {
    scenes = {}, --TODO: might be better to register these in a separate game scene file
}

---@type Scene[]
local scenesList = {}

---@param scene Scene
function SceneManager.transition(scene)
    for _, s in ipairs(scenesList) do
        if not s.isGlobal and s.isActive then
            s:stop()
        end
    end
    scene:start()
end

---@param scene Scene
function SceneManager.openOverlay(scene)
    for _, s in ipairs(scenesList) do
        if not s.isGlobal and s.isActive then
            s:pauseInput()
        end
    end
    scene:start()
end

---@param scene Scene
function SceneManager.closeOverlay(scene)
    scene:stop()
    for _, s in ipairs(scenesList) do
        if not s.isGlobal and s.isActive then
            s:resumeInput()
        end
    end
end

--- SCENE PROCESSING ---

---@param sceneName string
---@param scene Scene
function SceneManager.register(sceneName, scene)
    table.insert(scenesList, scene)
    SceneManager.scenes[sceneName] = scene
end

---@param baseScene Scene
---@param fn fun(scene: Scene)
local function processSceneStack(baseScene, fn)
    while baseScene do
        fn(baseScene)
        baseScene = baseScene.subScene
    end
end

---@param fn fun(scene: Scene)
local function processScenes(fn)
    for _, scene in ipairs(scenesList) do
        processSceneStack(scene, fn)
    end
end

---@param scene Scene
local function load(scene)
    processSceneStack(scene, function(scene)
        assert(not scene.isActive, "can't load an active scene")
        if scene.load then
            scene:load()
        end
        scene.isActive = true
        scene.shouldLoad = false
    end)
end

---@param scene Scene
local function unload(scene)
    processSceneStack(scene, function(scene)
        assert(scene.isActive, "can't unload an inactive scene")
        if scene.unload then
            scene:unload()
        end
        scene.isActive = false
        scene.shouldUnload = false
    end)
end

---@param scene Scene
---@return boolean
local function shouldSkipUpdate(scene)
    return not scene.isActive or scene.isPaused
end

---@param scene Scene
---@return boolean
local function shouldSkipInput(scene)
    return not scene.isActive or scene.isInputPaused
end

---@param scene Scene
---@return boolean
local function shouldSkipDraw(scene)
    return not scene.isActive
end

---@param key love.KeyConstant
---@param scancode love.Scancode
---@param isRepeat boolean
function SceneManager.keypressed(key, scancode, isRepeat)
    processScenes(function(scene)
        if shouldSkipInput(scene) then
            return
        end

        if scene.keypressed then
            scene:keypressed(key, scancode, isRepeat)
        end
    end)
end

---@param key love.KeyConstant
---@param scancode love.Scancode
function SceneManager.keyreleased(key, scancode)
    processScenes(function(scene)
        if shouldSkipInput(scene) then
            return
        end

        if scene.keyreleased then
            scene:keyreleased(key, scancode)
        end
    end)
end

---@param x number
---@param y number
---@param button number
---@param isTouch boolean
---@param presses number
function SceneManager.mousepressed(x, y, button, isTouch, presses)
    processScenes(function(scene)
        if shouldSkipInput(scene) then
            return
        end

        if scene.mousepressed then
            scene:mousepressed(x, y, button, isTouch, presses)
        end
    end)
end

---@param x number
---@param y number
---@param dx number
---@param dy number
---@param isTouch boolean
function SceneManager.mousemoved(x, y, dx, dy, isTouch)
    processScenes(function(scene)
        if shouldSkipInput(scene) then
            return
        end

        if scene.mousemoved then
            scene:mousemoved(x, y, dx, dy, isTouch)
        end
    end)
end

---@param x number
---@param y number
function SceneManager.wheelmoved(x, y)
    processScenes(function(scene)
        if shouldSkipInput(scene) then
            return
        end

        if scene.wheelmoved then
            scene:wheelmoved(x, y)
        end
    end)
end

---@param dt number
function SceneManager.update(dt)
    processScenes(function(scene)
        if scene.shouldUnload then
            unload(scene)
        end
        if scene.shouldLoad then
            load(scene)
        end

        if shouldSkipUpdate(scene) then
            return
        end

        if scene.update then
            scene:update(dt)
        end
    end)
end

function SceneManager.draw()
    processScenes(function(scene)
        if shouldSkipDraw(scene) then
            return
        end

        if scene.draw then
            scene:draw()
        end
    end)
end

return SceneManager
