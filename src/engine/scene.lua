local scene = {}

local scenes = {}

local function new(
	load,
	unload,
	update,
	draw
)
	return {
		isActive = false,
		isPaused = false,
		shouldLoad = false,
		shouldUnload = false,

		load,
		unload,
		update,
		draw
	}
end

function scene.registerScene(
	load,
	unload,
	update,
	draw
)
	local newScene = new(
		load,
		unload,
		update,
		draw
	)
	table.insert(scenes, newScene)

	return #scenes
end

function scene.start(sceneIdx)
	scene.isPaused = false
	scene.shouldLoad = true
end

function scene.stop(sceneIdx)
	scene.shouldUnload = true
end

function scene.pause(sceneIdx)
	scene.isPaused = true
end

function scene.resume(sceneIdx)
	scene.isPaused = false
end

function scene.transition(fromSceneIdx, toSceneIdx)
	scene.stop(fromSceneIdx)
	scene.start(toSceneIdx)
end

local function load(sceneToLoad)
	sceneToLoad.load()
	sceneToLoad.isActive = true
	sceneToLoad.shouldLoad = false
end

local function unload(sceneToUnload)
	sceneToUnload.unload()
	sceneToUnload.isActive = false
	sceneToUnload.shouldUnload = false
end

function scene.update()
	for _, scene in ipairs(scenes) do
		if scene.shouldUnload then
			load(scene)
		end
		if scene.shouldLoad then
			unload(scene);
		end

		if not scene.isActive or scene.isPaused then
			goto continue
		end

		scene.update()
		scene.draw()

		::continue::
	end
end

return scene
