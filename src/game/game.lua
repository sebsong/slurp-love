local tilemap = require("engine/tilemap")

local game = {}

function game.load()
	game.landTileLayerIndex = 1
	game.objectTileLayerIndex = 2

	game.landTilesetIndex = 1
	game.packageTilesetIndex = 2
	game.buildingTilesetIndex = 3
	game.mailboxTilesetIndex = 4
	local tilesets = {
		-- TODO: maybe switch to reading lua exported tiled files to get the grid size info
		tilemap.newTileset("assets/art/tileset.png", 16, 16),
		tilemap.newTileset("assets/art/packages.png", 16, 16),
		tilemap.newTileset("assets/art/buildings.png", 64, 64),
		tilemap.newTileset("assets/art/mailboxes.png", 16, 16),
		tilemap.newTileset("assets/art/walls.png", 16, 256),
	}
	game.tilemap = tilemap.newTilemapLua("assets/tilemap/map.lua", tilesets)
end

return game
