local set = {}

local meta = {}
meta.__index = meta

function set.new(...)
	local newSet = {
		_length = 0
	}
	setmetatable(newSet, meta)

	newSet:insert(...)

	return newSet
end

local function insert(_set, val)
	if not _set[val] then
		_set[val] = true
		_set._length = _set._length + 1
	end
end

function meta:insert(val, ...)
	if getmetatable(val) == meta then
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

local function remove(_set, val)
	if _set[val] then
		_set[val] = nil
		_set._length = _set._length - 1
	end
end

function meta:remove(val, ...)
	if getmetatable(val) == meta then
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

function meta:contains(item)
	return self[item] ~= nil
end

function meta:len()
	return self._length
end

function meta:isEmpty()
	return self:len() == 0
end

function meta:toArray()
	local array = {}
	for item, _ in pairs(self) do
		table.insert(array, item)
	end
	return array
end

function meta:__add(_otherSet)
	local union = set.new(self)
	union:insert(_otherSet)
	return union
end

function meta:__sub(_otherSet)
	local intersection = set.new(self)
	intersection:remove(_otherSet)
	return intersection
end

function meta:__tostring()
	local items = {}
	for key, _ in pairs(self) do
		table.insert(items, key)
	end
	return string.format("{%s}", table.concat(items, ", "))
end

return set
