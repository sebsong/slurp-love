local scene = {
	scenes = {}
}

local function init(_scene)
	assert(_scene.load, "Scene missing load method")
	assert(_scene.unload, "Scene missing unload method")
	assert(_scene.update, "Scene missing update method")
	assert(_scene.draw, "Scene missing draw method")

	_scene.isActive = false
	_scene.isPaused = false
	_scene.shouldLoad = false
	_scene.shouldUnload = false
	return _scene
end

function scene.register(sceneName, _scene)
	scene.scenes[sceneName] = init(_scene)
end

function scene.start(_scene)
	_scene.isPaused = false
	_scene.shouldLoad = true
end

function scene.stop(_scene)
	_scene.shouldUnload = true
end

function scene.pause(_scene)
	_scene.isPaused = true
end

function scene.resume(_scene)
	_scene.isPaused = false
end

function scene.transition(fromScene, toScene)
	scene.stop(fromScene)
	scene.start(toScene)
end

local function load(_scene)
	assert(not _scene.isActive, "can't load an active scene")
	_scene.load()
	_scene.isActive = true
	_scene.shouldLoad = false
end

local function unload(_scene)
	assert(_scene.isActive, "can't unload an inactive scene")
	_scene.unload()
	_scene.isActive = false
	_scene.shouldUnload = false
end

local function shouldSkip(_scene)
	return not _scene.isActive or _scene.isPaused
end

function scene.keypressed(key, scancode, isRepeat)
	for _, _scene in pairs(scene.scenes) do
		if shouldSkip(_scene) then
			goto continue
		end

		if scene.keypressed then
			_scene.keypressed(key, scancode, isRepeat)
		end

		::continue::
	end
end

function scene.mousepressed(x, y, button, isTouch, presses)
	for _, _scene in pairs(scene.scenes) do
		if shouldSkip(_scene) then
			goto continue
		end

		if scene.mousepressed then
			_scene.mousepressed(x, y, button, isTouch, presses)
		end

		::continue::
	end
end

function scene.mousemoved(x, y, dx, dy, isTouch)
	for _, _scene in pairs(scene.scenes) do
		if shouldSkip(_scene) then
			goto continue
		end

		if scene.mousemoved then
			_scene.mousemoved(x, y, dx, dy, isTouch)
		end

		::continue::
	end
end

function scene.wheelmoved(x, y)
	for _, _scene in pairs(scene.scenes) do
		if shouldSkip(_scene) then
			goto continue
		end

		if scene.wheelmoved then
			_scene.wheelmoved(x, y)
		end

		::continue::
	end
end

function scene.update(dt)
	for _, _scene in pairs(scene.scenes) do
		if _scene.shouldUnload then
			unload(_scene);
		end
		if _scene.shouldLoad then
			load(_scene)
		end

		if shouldSkip(_scene) then
			goto continue
		end

		_scene.update(dt)

		::continue::
	end
end

function scene.draw()
	for _, _scene in pairs(scene.scenes) do
		if shouldSkip(_scene) then
			goto continue
		end

		_scene.draw()

		::continue::
	end
end

return scene
