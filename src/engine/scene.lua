local Scene = {
    scenes = {},
}

local scenesList = {}

local function init(scene, isGlobal)
    assert(scene.load, "Scene %s missing load method")
    assert(scene.unload, "Scene missing unload method")
    assert(scene.onPause, "Scene missing onPause method")
    assert(scene.onResume, "Scene missing onResume method")
    assert(scene.update, "Scene missing update method")
    assert(scene.draw, "Scene missing draw method")

    scene.isGlobal = isGlobal
    scene.isActive = false
    scene.isPaused = false
    scene.isInputPaused = false
    scene.shouldLoad = false
    scene.shouldUnload = false
    return scene
end

function Scene.register(sceneName, scene, isGlobal)
    table.insert(scenesList, scene)
    Scene.scenes[sceneName] = init(scene, isGlobal or false)
end

function Scene.start(scene)
    scene.isPaused = false
    scene.shouldLoad = true
end

function Scene.stop(scene)
    scene.shouldUnload = true
end

function Scene.pause(scene)
    scene.onPause()
    scene.isPaused = true
end

function Scene.resume(scene)
    scene.onResume()
    scene.isPaused = false
end

function Scene.pauseInput(scene)
    scene.isInputPaused = true
end

function Scene.resumeInput(scene)
    scene.isInputPaused = false
end

function Scene.restart(scene)
    Scene.stop(scene)
    Scene.start(scene)
end

function Scene.transition(scene)
    for _, s in ipairs(scenesList) do
        if not s.isGlobal and s.isActive then
            Scene.stop(s)
        end
    end
    Scene.start(scene)
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
    return scene.isInputPaused or shouldSkipUpdate(scene)
end

local function shouldSkipDraw(scene)
    return not scene.isActive
end

function Scene.keypressed(key, scancode, isRepeat)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if Scene.keypressed then
            scene.keypressed(key, scancode, isRepeat)
        end

        ::continue::
    end
end

function Scene.mousepressed(x, y, button, isTouch, presses)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if Scene.mousepressed then
            scene.mousepressed(x, y, button, isTouch, presses)
        end

        ::continue::
    end
end

function Scene.mousemoved(x, y, dx, dy, isTouch)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if Scene.mousemoved then
            scene.mousemoved(x, y, dx, dy, isTouch)
        end

        ::continue::
    end
end

function Scene.wheelmoved(x, y)
    for _, scene in ipairs(scenesList) do
        if shouldSkipInput(scene) then
            goto continue
        end

        if Scene.wheelmoved then
            scene.wheelmoved(x, y)
        end

        ::continue::
    end
end

function Scene.update(dt)
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

function Scene.draw()
    for _, scene in ipairs(scenesList) do
        if shouldSkipDraw(scene) then
            goto continue
        end

        scene.draw()

        ::continue::
    end
end

return Scene
