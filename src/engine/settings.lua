---@class Settings
---@field canvasPixelWidth integer
---@field canvasPixelHeight integer
local Settings = {}

Settings.IS_DEBUG = os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" and arg[2] == "debug"

Settings.canvasPixelWidth = 640
Settings.canvasPixelHeight = 360

return Settings
