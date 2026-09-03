local Camera = require("engine.camera")
local Mailbox = require("game.mailbox")
local Math = require("engine.math")
local Mesh = require("engine.mesh")
local Render = require("engine.render")
local SceneManager = require("engine.scene_manager")
local Sprite = require("engine.sprite")
local Tilemap = require("engine.tilemap")
local Vec2 = require("engine.vec2")

local Boat = require("game.scenes.boat")
local BoatEffect = require("game.effects.boat_effect")
local DayTracker = require("game.scenes.day_tracker")
local GameUi = require("game.ui")
local LanternEffect = require("game.effects.lantern_effect")
local MailDialogue = require("game.scenes.mail_dialogue")
local MailScript = require("game.scenes.mail_script")
local MailboxEffect = require("game.effects.mailbox_effect")
local Map = require("game.scenes.map")
local Music = require("game.music")
local Package = require("game.package")
local PackageEffect = require("game.effects.package_effect")
local TileEffect = require("game.effects.tile_effect")
local WaterEffect = require("game.effects.water_effect")

---@class Game: Scene
local Game = {}

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
local LAND_TILESET_SIZE = 3
local PACKAGES_TILESET_NAME = "packages"
local BUILDINGS_TILESET_NAME = "buildings"
local BUILDINGS_TILESET_SIZE = 2
local MAILBOX_TILESET_NAME = "mailboxes"
local WALLS_TILESET_NAME = "walls"

local LAND_TILE_ID = 1
local FLOATING_TILE_ID = 2

local tilemapWorldRows
local tilemapFloatingWorldRows
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

local pauseTimer
local elapsedSeconds
local shaderSeconds

local didWin
local didLose

function Game.load()
    pauseTimer = true
    elapsedSeconds = 0
    shaderSeconds = 0
    didWin = false
    didLose = false

    Package.load()
    GameUi.load()
    Music.load()

    cameraObj = Camera.new()

    local currentDay = DayTracker.currentDay

    OBJECT_LAYER_NAME = DAY_TO_LAYER_NAME[currentDay] or OBJECT_LAYER_NAME

    local landTilesImage = love.graphics.newImage("assets/art/tileset.png")
    local landTileSprite = Sprite.newTiled(landTilesImage, LAND_TILESET_SIZE, 1)
    local landQuadWidth, landQuadHeight = Sprite.calculateQuadDimensions(landTilesImage, LAND_TILESET_SIZE, 1, 1)

    local packagesImage = love.graphics.newImage("assets/art/packages.png")

    local buildingsImage = love.graphics.newImage("assets/art/buildings.png")
    local buildingTileSprite = Sprite.newTiled(buildingsImage, BUILDINGS_TILESET_SIZE, 1)
    local buildingQuadWidth, buildingQuadHeight =
        Sprite.calculateQuadDimensions(buildingsImage, BUILDINGS_TILESET_SIZE, 1, 1)

    local mailboxesImage = love.graphics.newImage("assets/art/mailboxes.png")

    tilemapObj = Tilemap.newTilemapLua("assets/tilemap/map.lua")

    worldObjects = {}
    packages = {}
    mailboxes = {}

    boatObj = Boat.new(tilemapObj, currentDay)
    table.insert(worldObjects, boatObj)

    waterImage = love.graphics.newImage("assets/art/water.png")
    WaterEffect.load(cameraObj, boatObj, love.timer.getTime())

    TileEffect.load(cameraObj, boatObj)

    lanternLightImage = love.graphics.newImage("assets/art/lantern_light.png")
    local lanternXDiameter, lanternYDiameter = lanternLightImage:getDimensions()
    lanternXRadius, lanternYRadius = lanternXDiameter / 2, lanternYDiameter / 2
    LanternEffect.load()

    PackageEffect.load()
    MailboxEffect.load()

    tilemapWorldRows = {}
    tilemapFloatingWorldRows = {}

    local tilesByRow = {}

    local landTiles = tilemapObj.layers[LAND_LAYER_NAME].tiles
    for _, row in ipairs(landTiles) do
        for _, tile in ipairs(row) do
            if not tile.tileId then
                goto continue
            end

            local worldRowTiles = tilesByRow[tile.worldRowIdx]
            if not worldRowTiles then
                worldRowTiles = {}
                tilesByRow[tile.worldRowIdx] = worldRowTiles
            end

            table.insert(worldRowTiles, tile)

            ::continue::
            ---
        end
    end

    for worldRowIdx, rowTiles in pairs(tilesByRow) do
        local quads = {}
        local positions = {}
        local positionAttrs = {}
        local quadViewportAttrs = {}
        local isFloatingAttrs = {}
        local inRangeAttrs = {}
        for _, tile in ipairs(rowTiles) do
            local worldX, worldY =
                tilemapObj.tilemapIndexToWorldTransform:transformPoint(tile.position.x, tile.position.y)
            local originX = worldX - landTileSprite.width / 2
            local originY = worldY - landTileSprite.height + tilemapObj.tileHeight / 2

            landTileSprite:transitionAnimationState(tile.tileId) -- TODO: jank
            local quad = landTileSprite:getCurrentQuad()

            table.insert(quads, quad)
            table.insert(positions, Vec2.new(originX, originY))
            table.insert(positionAttrs, Vec2.new(originX, originY))
            table.insert(quadViewportAttrs, { quad:getViewport() })
            table.insert(inRangeAttrs, { 0 })
            if tile.tileId == LAND_TILE_ID then
                table.insert(isFloatingAttrs, { 0 })
            elseif tile.tileId == FLOATING_TILE_ID then
                table.insert(isFloatingAttrs, { 1 })
            end
        end
        -- TODO: maybe we can attach all these attributes together?
        local mesh = Mesh.new(landTilesImage, quads, positions, nil, "static", 0, 0, worldRowIdx)
        mesh:attachAttribute({ "v_quadViewport", "float", 4 }, quadViewportAttrs)
        mesh:attachAttribute({ "v_tilePosition", "float", 2 }, positionAttrs)
        mesh:attachAttribute({ "v_isFloating", "float", 1 }, isFloatingAttrs)
        mesh:attachAttribute({ "v_inRange", "float", 1 }, inRangeAttrs)
        mesh.setShader = function()
            TileEffect.setShader()
        end
        local worldRow = {
            renderable = mesh,
        }
        tilemapWorldRows[worldRowIdx] = worldRow
    end

    for _, object in ipairs(tilemapObj.layers[OBJECT_LAYER_NAME].objects) do
        local tilesetName = object.tilesetName
        if tilesetName == PACKAGES_TILESET_NAME then
            local packageObj = Package.new(packagesImage, object, tilemapObj)
            table.insert(packages, packageObj)
        elseif tilesetName == MAILBOX_TILESET_NAME then
            local mailboxObj = Mailbox.new(mailboxesImage, object, tilemapObj)
            table.insert(mailboxes, mailboxObj)
        end
    end

    for _, mailbox in ipairs(mailboxes) do
        for _, package in ipairs(packages) do
            if mailbox.id == package.destinationId then
                mailbox.package = package
                package.mailbox = mailbox
                break
            end
        end
    end

    tilemapBuildingsSpriteBatch = love.graphics.newSpriteBatch(buildingsImage, 200, "static")
    for _, object in ipairs(tilemapObj.layers[BUILDINGS_LAYER_NAME].objects) do
        local x, y = object.transform:transformPoint(0, 0)
        local xOffset = -buildingQuadWidth / 2
        local yOffset = -buildingQuadWidth + tilemapObj.tileHeight / 2
        buildingTileSprite:transitionAnimationState(object.tileId) -- TODO: jank
        tilemapBuildingsSpriteBatch:add(buildingTileSprite:getCurrentQuad(), x + xOffset, y + yOffset)
    end

    MailDialogue.open(MailScript.dailyDialogue[currentDay], function()
        pauseTimer = false
    end)
end

function Game.unload()
    Music:unload()
    love.audio.stop()
end

function Game.onPause()
    pauseTimer = true
    boatObj.engineLoopSound:pause()
end

function Game.onResume()
    pauseTimer = false
    boatObj.engineLoopSound:play()
end

function Game.onPauseInput()
    Game.onPause()
    boatObj:releaseInput()
end

function Game.onResumeInput()
    Game.onResume()
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
    DayTracker.nextDay(boatObj.gasRemaining, elapsedSeconds)
end

local function gameOver()
    if not SceneManager.scenes.gameOverMenu.isActive then
        SceneManager.scenes.gameOverMenu:start()
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

    if boatObj.gasRemaining <= 0 and math.abs(boatObj.speed) == 0 and not boatObj:getDeliveryMailbox(mailboxes) then
        gameOver()
    end
end

function Game.keypressed(key, scancode, isRepeat)
    if key == "space" and not isRepeat then
        if not boatObj:pickupPackage(packages, mailboxes) then
            boatObj:deliverPackage(mailboxes)
        end
    end

    if key == "t" and not isRepeat then
        WaterEffect.load(cameraObj, boatObj, love.timer.getTime())
    end

    if key == "r" and not isRepeat then
        SceneManager.scenes.game:restart()
    end

    if key == "tab" then
        Map.open()
    end

    cameraObj:keypressed(key, scancode, isRepeat)
    boatObj:keypressed(key, scancode, isRepeat)
end

function Game.keyreleased(key, scancode)
    if key == "tab" then
        Map.close()
    end
    boatObj:keyreleased(key, scancode)
end

function Game.mousepressed(x, y, button, isTouch, presses)
    cameraObj:mousepressed(x, y, button, isTouch, presses)
end

function Game.mousemoved(x, y, dx, dy, isTouch)
    cameraObj:mousemoved(x, y, dx, dy, isTouch)
end

function Game.wheelmoved(x, y)
    cameraObj:wheelmoved(x, y)
end

function Game.update(dt)
    if not pauseTimer then
        elapsedSeconds = elapsedSeconds + dt
        boatObj:update(dt)
    end

    for _, packageObj in ipairs(boatObj.packages) do
        packageObj:update(dt)
    end

    if not cameraObj.isPanning then
        local boatX, boatY = boatObj.moveTransform:transformPoint(0, 0)
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

    -- TODO: maybe these are entities to render
    -- renderables or drawables have: transform, render info (offsets), drawable (image, sprite batch, mesh)
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
        local zIndex = worldObject.renderable:getZIndex()
        if Math.inRange(zIndex, startWorldRowIdx, endWorldRowIdx) then
            table.insert(worldEntities, worldObject)
        end
    end

    Render.zSort(worldEntities, function(item)
        return item.renderable
    end)

    for _, mailbox in ipairs(mailboxes) do
        mailbox:update(dt)
    end

    shaderSeconds = shaderSeconds + dt
    WaterEffect.update(cameraObj, boatObj, shaderSeconds)
    BoatEffect.update(cameraObj, shaderSeconds)
    TileEffect.update(cameraObj, boatObj, shaderSeconds)
    LanternEffect.update(cameraObj, shaderSeconds)
    PackageEffect.update(boatObj, packages)
    MailboxEffect.update(boatObj, mailboxes)

    evaluateWinCondition()
    evaluateLoseCondition()
end

function Game.draw()
    WaterEffect.setShader()
    love.graphics.draw(waterImage)
    love.graphics.setShader()

    love.graphics.push()
    love.graphics.scale(cameraObj.zoom, cameraObj.zoom)
    love.graphics.applyTransform(Camera.getWorldToCanvasTransform(cameraObj))

    for _, worldObject in ipairs(worldEntities) do
        worldObject.renderable:draw(worldObject.transform)
    end

    for _, package in ipairs(packages) do
        package.sprite:draw(package.transform)
    end
    for _, mailbox in ipairs(mailboxes) do
        mailbox.sprite:draw(mailbox.transform)
    end
    love.graphics.setShader()
    love.graphics.draw(tilemapBuildingsSpriteBatch)

    if boatObj.isLanternActive then
        local boatX, boatY = boatObj.moveTransform:transformPoint(0, 0)
        LanternEffect.setShader()
        love.graphics.draw(lanternLightImage, boatX - lanternXRadius, boatY - lanternYRadius)
    end

    love.graphics.pop()

    GameUi.draw(boatObj.gasRemaining, boatObj.packages)
end

function Game.debugTeleportBoatToCanvasPoint(x, y)
    local canvasToWorldTransform = Camera.getCanvasToWorldTransform(cameraObj)
    local targetWorldPoint = Vec2.new(canvasToWorldTransform:transformPoint(x, y))
    boatObj.moveTransform:setTransformation(targetWorldPoint.x, targetWorldPoint.y, boatObj.rotation)
end

return Game
