---@class AssetLoader
---@field private assets table
local AssetLoader = {
    assets = {},
}

function AssetLoader.load(path, loadFn)
    AssetLoader.assets[path] = loadFn(path)
end

function AssetLoader.hotReload() end

function AssetLoader.get(path) end

return AssetLoader
