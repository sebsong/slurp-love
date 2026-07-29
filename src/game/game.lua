local game = {}

local Color = require("engine/color")
local Tilemap = require("engine/tilemap")
local Camera = require("engine/camera")
local Sprite = require("engine/sprite")
local Scene = require("engine/scene")
local Math = require("engine/math")
local Vec2 = require("engine/vec2")

local GameUi = require("game/ui")
local Music = require("game/music")
local Boat = require("game/boat")
local Package = require("game/package")
local DayTracker = require("game/day_tracker")
local MailDialogue = require("game/mail_dialogue")
local MailScript = require("game/mail_script")
local Map = require("game/map")
local WaterEffect = require("game/effects/water_effect")
local TileEffect = require("game/effects/tile_effect")
local LanternEffect = require("game/effects/lantern_effect")
local PackageEffect = require("game/effects/package_effect")
local MailboxEffect = require("game/effects/mailbox_effect")

local DAY_TO_LAYER_NAME = {
	"objects_monday",
	"objects_tuesday",
	"objects_wednesday",
	"objects_thursday",
	"objects_friday",
}

local LAND_LAYER_NAME = "base"
local OBJECT_LAYER_NAME = "objects_monday"
local BUILDINGS_LAYER_NAME = "buildings"

local LAND_TILESET_NAME = "tileset"
local PACKAGES_TILESET_NAME = "packages"
local BUILDINGS_TILESET_NAME = "buildings"
local MAILBOX_TILESET_NAME = "mailboxes"
local WALLS_TILESET_NAME = "walls"

local FLOATING_TILE_ID = 2

local tilemapWorldRows
local tilemapFloatingWorldRows
local tilemapWallsSpriteBatch
local tilemapBuildingsSpriteBatch

local tilemapObj
local cameraObj
local boatObj

local worldEntities
local worldObjects
local packages
local mailboxes

local waterImage

local lanternLightImage
local lanternXRadius
local lanternYRadius

local didWin
local didLose

function game.load()
	didWin = false
	didLose = false

	Color.loadPalette("assets/art/retrotronic-dx.hex")
	Package.load()
	GameUi.load()
	Music.load()

	cameraObj = Camera.new()

	local currentDay = Scene.scenes.dayTracker.currentDay

	OBJECT_LAYER_NAME = DAY_TO_LAYER_NAME[currentDay] or OBJECT_LAYER_NAME

	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		Tilemap.newTileset("assets/art/tileset.png", 16, 16),
		Tilemap.newTileset("assets/art/packages.png", 16, 16),
		Tilemap.newTileset("assets/art/buildings.png", 64, 64),
		Tilemap.newTileset("assets/art/mailboxes.png", 16, 16),
		Tilemap.newTileset("assets/art/walls.png", 16, 256),
	}
	tilemapObj = Tilemap.newTilemapLua("assets/tilemap/map.lua", tilesets)

	worldObjects = {}
	packages = {}
	mailboxes = {}

	boatObj = Boat.new(tilemapObj, currentDay)
	table.insert(worldObjects, boatObj)

	waterImage = love.graphics.newImage("assets/art/water.png")
	WaterEffect.load(cameraObj, boatObj, love.timer.getTime())

	TileEffect.load(cameraObj, boatObj)

	lanternLightImage                        = love.graphics.newImage("assets/art/lantern_light.png")
	local lanternXDiameter, lanternYDiameter = lanternLightImage:getDimensions()
	lanternXRadius, lanternYRadius           = lanternXDiameter / 2, lanternYDiameter / 2
	LanternEffect.load()

	PackageEffect.load()
	MailboxEffect.load()

	local spriteBatchSize = math.max(tilemapObj.width, tilemapObj.height)
	tilemapWallsSpriteBatch = love.graphics.newSpriteBatch(tilesets[5].image, spriteBatchSize * 4, "static")
	tilemapWorldRows = {}
	tilemapFloatingWorldRows = {}
	for _, row in ipairs(tilemapObj.layers[LAND_LAYER_NAME].tiles) do
		for _, tile in ipairs(row) do
			if not tile.tileId then
				goto continue
			end

			local tileset = tilesets[tile.tilesetIndex]
			local tileImage = tileset.image
			local tileQuad = tileset.quads[tile.tileId]
			local _, _, width, height = tileQuad:getViewport()
			local x, y = tilemapObj.tilemapIndexToWorldTransform:transformPoint(tile.position.x, tile.position.y)

			if tile.tilesetName == WALLS_TILESET_NAME then
				tilemapWallsSpriteBatch:add(
					tileQuad,
					x - width / 2,
					y - height + tilemapObj.tileHeight / 2
				)
				goto continue
			end

			if tile.tilesetName == LAND_TILESET_NAME and tile.tileId == FLOATING_TILE_ID then
				local xOffset = -width / 2
				local yOffset = -height + tilemapObj.tileHeight / 2
				local zIndex = tile.zIndex
				local zIndexOffset = tile.zIndexOffset
				local tileObj = {
					transform = love.math.newTransform(x, y),
					drawComponent = Sprite.new(tileImage, tileQuad, xOffset, yOffset, zIndex, zIndexOffset),
					tileQuad = tileQuad,
					isFloating = true,
				}
				tileObj.drawComponent.setShader = function()
					TileEffect.setShader(tileObj, boatObj, lanternXRadius, lanternYRadius)
				end
				table.insert(worldObjects, tileObj)
				goto continue
			end

			local tilemapWorldRow = tilemapWorldRows[tile.worldRowIdx]
			if not tilemapWorldRow then
				local spriteBatch = love.graphics.newSpriteBatch(tileImage, spriteBatchSize, "static")
				tilemapWorldRow = {
					transform = love.math.newTransform(0, y),
					drawComponent = Sprite.newSpriteBatch(spriteBatch, tileQuad, tile.zIndex, tile.zIndexOffset),
					tileQuad = tileQuad,
					isFloating = false,
				}
				tilemapWorldRow.drawComponent.setShader = function()
					TileEffect.setShader(tilemapWorldRow, boatObj, lanternXRadius, lanternYRadius)
				end
				tilemapWorldRows[tile.worldRowIdx] = tilemapWorldRow
			end
			tilemapWorldRow.drawComponent.image:add(
				tileQuad,
				x - width / 2,
				-height + tilemapObj.tileHeight / 2
			)
			::continue::
		end
	end

	for _, object in ipairs(tilemapObj.layers[OBJECT_LAYER_NAME].objects) do
		local tilesetName = object.tilesetName
		if (tilesetName == PACKAGES_TILESET_NAME) then
			local packageObj = Package.toPackage(object)
			table.insert(packages, packageObj)
			object.drawComponent.setShader = function()
				PackageEffect.setShader(packageObj)
			end
		elseif (tilesetName == MAILBOX_TILESET_NAME) then
			table.insert(mailboxes, object)
			object.drawComponent.setShader = function()
				MailboxEffect.setShader(object)
			end
		end

		table.insert(worldObjects, object)
	end

	for _, mailbox in ipairs(mailboxes) do
		for _, packageObj in ipairs(packages) do
			if mailbox.id == packageObj.destinationId then
				mailbox.package = packageObj
				packageObj.mailbox = mailbox
				break
			end
		end
	end

	tilemapBuildingsSpriteBatch = love.graphics.newSpriteBatch(tilesets[3].image, 200, "static")
	for _, object in ipairs(tilemapObj.layers[BUILDINGS_LAYER_NAME].objects) do
		local x, y = object.transform:transformPoint(0, 0)
		tilemapBuildingsSpriteBatch:add(
			object.drawComponent.quad,
			x + object.drawComponent.xOffset,
			y + object.drawComponent.yOffset
		)
	end

	Scene.pauseInput(Scene.scenes.game)
	MailDialogue.open(
		MailScript.dailyDialogue[currentDay],
		function() Scene.resumeInput(Scene.scenes.game) end
	)
end

function game.unload()
	Music:unload()
	love.audio.stop()
end

function game.onPause()
	boatObj.engineLoopSound:pause()
end

function game.onResume()
	boatObj.engineLoopSound:play()
end

function game.endDay()
	Scene.scenes.dayTracker.nextDay()
	Scene.transition(Scene.scenes.dayTracker)
end

local function victory()
	if not Scene.scenes.victoryMenu.isActive then
		Scene.start(Scene.scenes.victoryMenu)
	end
end

local function evaluateWinCondition()
	if didLose then
		return
	end

	for _, packageObj in ipairs(packages) do
		if not packageObj.isDelivered then
			return
		end
	end

	didWin = true
	if DayTracker.currentDay == DayTracker.FINAL_DAY then
		victory()
	else
		game.endDay()
	end
end

local function gameOver()
	if not Scene.scenes.gameOverMenu.isActive then
		Scene.start(Scene.scenes.gameOverMenu)
	end
	didLose = true
end

local function evaluateLoseCondition()
	if didWin then
		return
	end

	for _, packageObj in ipairs(boatObj.packages) do
		if not packageObj.canDeliver then
			gameOver()
			break
		end
	end

	if boatObj.gasRemaining <= 0
		and math.abs(boatObj.speed) == 0
		and not boatObj:getDeliveryMailbox(mailboxes) then
		gameOver()
	end
end

function game.keypressed(key, scancode, isRepeat)
	if key == "space" and not isRepeat then
		if not boatObj:pickupPackage(packages, mailboxes) then
			boatObj:deliverPackage(mailboxes)
		end
	end

	if key == "t" and not isRepeat then
		WaterEffect.load(cameraObj, boatObj, love.timer.getTime())
	end

	if key == "r" and not isRepeat then
		Scene.restart(game)
	end

	if key == "tab" then
		if not Scene.scenes.map.isActive then
			Map.open()
		else
			Map.close()
		end
	end

	cameraObj:keypressed(key, scancode, isRepeat)
end

function game.mousepressed(x, y, button, isTouch, presses)
	cameraObj:mousepressed(x, y, button, isTouch, presses)
end

function game.mousemoved(x, y, dx, dy, isTouch)
	cameraObj:mousemoved(x, y, dx, dy, isTouch)
end

function game.wheelmoved(x, y)
	cameraObj:wheelmoved(x, y)
end

function game.update(dt)
	boatObj:update(cameraObj, dt)
	for _, packageObj in ipairs(boatObj.packages) do
		packageObj:update(dt)
	end

	if not cameraObj.isPanning then
		local boatX, boatY = boatObj.transform:transformPoint(0, 0)
		cameraObj.transform:setTransformation(boatX, boatY)
	end

	Music.update(boatObj, dt)

	local cameraX, cameraY = cameraObj.transform:transformPoint(0, 0)
	local cameraHalfHeight = cameraObj:getScreenHeight() / 2
	local startY, endY = cameraY - cameraHalfHeight, cameraY + cameraHalfHeight

	local startColIdx, startRowIdx = tilemapObj.worldToTilemapIndexTransform:transformPoint(cameraX, startY)
	local endColIdx, endRowIdx = tilemapObj.worldToTilemapIndexTransform:transformPoint(cameraX, endY)
	startColIdx = math.floor(startColIdx)
	startRowIdx = math.floor(startRowIdx)
	endColIdx = math.ceil(endColIdx)
	endRowIdx = math.ceil(endRowIdx)

	local startWorldRowIdx = Tilemap.getWorldRowIdx(startColIdx, startRowIdx)
	local endWorldRowIdx = Tilemap.getWorldRowIdx(endColIdx, endRowIdx) + 4

	worldEntities = {}
	for worldRowIdx = startWorldRowIdx, endWorldRowIdx do
		local worldRow = tilemapWorldRows[worldRowIdx]
		if worldRow then
			table.insert(worldEntities, worldRow)
		end
		local floatingWorldRow = tilemapFloatingWorldRows[worldRowIdx]
		if floatingWorldRow then
			table.insert(worldEntities, floatingWorldRow)
		end
	end
	for _, worldObject in ipairs(worldObjects) do
		local zIndex = worldObject.drawComponent.zIndex + worldObject.drawComponent.zIndexOffset
		if Math.inRange(zIndex, startWorldRowIdx, endWorldRowIdx) then
			table.insert(worldEntities, worldObject)
		end
	end

	table.sort(
		worldEntities,
		function(entity, otherEntity)
			local entityZIndex = entity.drawComponent.zIndex + entity.drawComponent.zIndexOffset
			local otherEntityZIndex = otherEntity.drawComponent.zIndex + otherEntity.drawComponent.zIndexOffset
			return entityZIndex < otherEntityZIndex
		end
	)

	WaterEffect.update(cameraObj, boatObj)
	TileEffect.update(cameraObj, boatObj)
	LanternEffect.update(cameraObj)
	PackageEffect.update(boatObj, packages)
	MailboxEffect.update(boatObj, mailboxes)

	evaluateWinCondition()
	evaluateLoseCondition()
end

function game.draw()
	WaterEffect.setShader()
	love.graphics.draw(waterImage)
	love.graphics.setShader()

	love.graphics.push()
	love.graphics.scale(cameraObj.zoom, cameraObj.zoom)
	love.graphics.applyTransform(Camera.getWorldToCanvasTransform(cameraObj))

	love.graphics.draw(tilemapWallsSpriteBatch)
	for _, worldObject in ipairs(worldEntities) do
		Sprite.draw(worldObject.drawComponent, worldObject.transform)
	end
	love.graphics.setShader()
	love.graphics.draw(tilemapBuildingsSpriteBatch)

	if boatObj.isLanternActive then
		local boatX, boatY = boatObj.transform:transformPoint(0, 0)
		LanternEffect.setShader()
		love.graphics.draw(lanternLightImage, boatX - lanternXRadius, boatY - lanternYRadius)
	end

	love.graphics.pop()

	GameUi.draw(boatObj.gasRemaining, boatObj.packages)
end

function game.debugTeleportBoatToCanvasPoint(x, y)
	local canvasToWorldTransform = Camera.getCanvasToWorldTransform(cameraObj)
	local targetWorldPoint = Vec2.new(canvasToWorldTransform:transformPoint(x, y))
	boatObj.transform:setTransformation(targetWorldPoint.x, targetWorldPoint.y, boatObj.rotation)
end

return game
