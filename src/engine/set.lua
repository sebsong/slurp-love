local set = {}

local meta = {}
meta.__index = meta

function set.new(...)
	local newSet = {}
	setmetatable(newSet, meta)

	newSet:insert(...)

	return newSet
end

function meta:insert(val, ...)
	if getmetatable(val) == meta then
		assert(... == nil, "shouldn't pass in more args if val is a set")
		for item, _ in pairs(val) do
			self[item] = true
		end
	else
		local items = { val, ... }
		for _, item in ipairs(items) do
			self[item] = true
		end
	end
end

function meta:remove(val, ...)
	if getmetatable(val) == meta then
		assert(... == nil, "shouldn't pass in more args if val is a set")
		for item, _ in pairs(val) do
			self[item] = nil
		end
	else
		local items = { val, ... }
		for _, item in ipairs(items) do
			self[item] = nil
		end
	end
end

function meta:contains(item)
	return self[item] ~= nil
end

function meta:toArray()
	local array = {}
	for item, _ in pairs(self) do
		table.insert(array, item)
	end
	return array
end

function meta.__add(_set, _otherSet)
	local union = set.new(_set)
	union:insert(_otherSet)
	return union
end

function meta.__sub(_set, _otherSet)
	local intersection = set.new(_set)
	intersection:remove(_otherSet)
	return intersection
end

function meta.__tostring(_set)
	local items = {}
	for key, _ in pairs(_set) do
		table.insert(items, key)
	end
	return string.format("{%s}", table.concat(items, ", "))
end

return set
