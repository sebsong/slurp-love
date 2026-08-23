local Serialization = require("engine.serialization")

---@class Save
local Save = {}

local SAVE_FILE_NAME = "save_data.slurp"

---@param data table
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

---@param updateFn fun(data: table)
function Save.update(updateFn)
    local saveData = Save.load()
    updateFn(saveData)
    Save.save(saveData)
end

---@return table
function Save.load()
    return Serialization.fileToTable(SAVE_FILE_NAME)
end

return Save
