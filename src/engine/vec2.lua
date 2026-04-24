local vec2 = {}

local metatable = {}
metatable.__index = metatable

function vec2.new(x, y)
	local newVec = {
		x = x or 0,
		y = y or 0,
	}
	setmetatable(newVec, metatable)

	return newVec
end

function metatable:magnitude()
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function metatable.__eq(vec, otherVec)
	return vec.x == otherVec.x and vec.y == otherVec.y
end

function metatable.__add(vec, otherVec)
	return vec2.new(vec.x + otherVec.x, vec.y + otherVec.y)
end

function metatable.__sub(vec, otherVec)
	return vec2.new(vec.x - otherVec.x, vec.y - otherVec.y)
end

function metatable.__mul(vec, scalar)
	assert(type(scalar) == "number")
	return vec2.new(vec.x * scalar, vec.y * scalar)
end

function metatable.__div(vec, scalar)
	assert(type(scalar) == "number")
	return vec2.new(vec.x / scalar, vec.y / scalar)
end

function metatable.__unm(vec)
	return vec2.new(-vec.x, -vec.y)
end

function metatable.__tostring(vec)
	return string.format("(%s, %s)", vec.x, vec.y)
end

return vec2
