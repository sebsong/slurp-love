---@class Set
---@field length number
---@
---@field new fun(...: any): Set
---@
---@field insert fun(self:Set, val: any, ...: any)
---@field remove fun(self:Set, val: any, ...: any)
---@field contains fun(self: Set, item: any): boolean
---@field len fun(self: Set): number
---@field isEmpty fun(self: Set): boolean
---@field toArray fun(self: Set): any[]
local Set = {}
Set.__index = Set

function Set.new(...)
    local set = {
        length = 0,
    }
    setmetatable(set, Set)

    set:insert(...)

    return set
end

local function insert(set, val)
    if not set[val] then
        set[val] = true
        set.length = set.length + 1
    end
end

function Set:insert(val, ...)
    if getmetatable(val) == Set then
        assert(... == nil, "shouldn't pass in more args if val is a set")
        for item, _ in pairs(val) do
            insert(self, item)
        end
    else
        local items = { val, ... }
        for _, item in ipairs(items) do
            insert(self, item)
        end
    end
end

local function remove(set, val)
    if set[val] then
        set[val] = nil
        set.length = set.length - 1
    end
end

function Set:remove(val, ...)
    if getmetatable(val) == Set then
        assert(... == nil, "shouldn't pass in more args if val is a set")
        for item, _ in pairs(val) do
            remove(self, item)
        end
    else
        local items = { val, ... }
        for _, item in ipairs(items) do
            remove(self, item)
        end
    end
end

function Set:contains(item)
    return self[item] ~= nil
end

function Set:len()
    return self.length
end

function Set:isEmpty()
    return self:len() == 0
end

function Set:toArray()
    local array = {}
    for item, _ in pairs(self) do
        table.insert(array, item)
    end
    return array
end

function Set:__add(_otherSet)
    local union = Set.new(self)
    union:insert(_otherSet)
    return union
end

function Set:__sub(_otherSet)
    local intersection = Set.new(self)
    intersection:remove(_otherSet)
    return intersection
end

function Set:__tostring()
    local items = {}
    for key, _ in pairs(self) do
        table.insert(items, key)
    end
    return string.format("{%s}", table.concat(items, ", "))
end

return Set
