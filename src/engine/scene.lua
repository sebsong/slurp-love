local scene = {}

local scenes = {}

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

function scene.register(_scene)
	table.insert(scenes, init(_scene))

	return #scenes
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
	_scene.load()
	_scene.isActive = true
	_scene.shouldLoad = false
end

local function unload(_scene)
	_scene.unload()
	_scene.isActive = false
	_scene.shouldUnload = false
end

function scene.update(dt)
	for _, _scene in ipairs(scenes) do
		if _scene.shouldUnload then
			unload(_scene);
		end
		if _scene.shouldLoad then
			load(_scene)
		end

		if not _scene.isActive or _scene.isPaused then
			goto continue
		end

		_scene.update(dt)

		::continue::
	end
end

function scene.draw()
	for _, _scene in ipairs(scenes) do
		if not _scene.isActive or _scene.isPaused then
			goto continue
		end

		_scene.draw()

		::continue::
	end
end

return scene
