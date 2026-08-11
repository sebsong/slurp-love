local Serialization = require("engine.serialization")

---@class Save
---@field save fun(data: table)
---@field update fun(updateFn: fun(data: table))
---@field load fun(): table
local Save = {}

local SAVE_FILE_NAME = "save_data.slurp"

function Save.save(data)
    Serialization.tableToFile(data, SAVE_FILE_NAME)
end

local function updateTable(tbl, update)
    for updateKey, updateVal in pairs(update) do
        local tableVal = tbl[updateKey]
        if type(tableVal) == "table" and type(updateVal) == "table" then
            updateTable(tableVal, updateVal)
        else
            tbl[updateKey] = updateVal
        end
    end
end

function Save.update(updateFn)
    local saveData = Save.load()
    updateFn(saveData)
    Save.save(saveData)
end

function Save.load()
    return Serialization.fileToTable(SAVE_FILE_NAME)
end

return Save
