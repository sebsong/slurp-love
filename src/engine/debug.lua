local Debug = {}

local Serialization = require("engine.serialization")

-- redefine global print to pretty print tables
local _print = print
print = function(...)
    local args = { ... }
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            args[i] = Serialization.tableToString(arg)
        end
    end
    _print(unpack(args))
end

local stopwatchTime

function Debug.stopwatch(label)
    local endTime = love.timer.getTime()
    local elapsedMs = stopwatchTime and (endTime - stopwatchTime) * 1000 or nil
    stopwatchTime = endTime
    if label then
        print(("%s: %s"):format(label, elapsedMs))
    end
    return elapsedMs
end

return Debug
