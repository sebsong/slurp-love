local set = {}

local meta = {}
meta.__index = meta

function set.new(...)
	local newSet = {}
	setmetatable(newSet, meta)

	newSet:insert(...)

	return newSet
end

function meta:insert(...)
	local items = { ... }
	-- if getmetatable(items) == meta
	for _, item in ipairs(items) do
		self[item] = true
	end
end

function meta:remove(...)
	for _, item in ipairs(...) do
		self[item] = nil
	end
end

function meta:contains(item)
	return self[item] ~= nil
end

function meta:size()
	return #self
end

-- function meta.__add(_set, _otherSet)
-- 	return _set.new(_set.x + _otherSet.x, _set.y + _otherSet.y)
-- end

-- function meta.__sub(_set, _otherSet)
-- 	return _set.new(_set.x - _otherSet.x, _set.y - _otherSet.y)
-- end

-- function meta.__unm(_set)
-- 	return _set.new(-_set.x, -_set.y)
-- end

function meta.__tostring(_set)
	local str = ""
	for k, v in pairs(_set) do
		str = str .. string.format("%s, ", k)
	end
	return str
end

local test = set.new(1, 2, 3)
print(test)
print(test:contains(2))
print(test:contains(4))
test:insert(4)
print(test:contains(4))

return set
