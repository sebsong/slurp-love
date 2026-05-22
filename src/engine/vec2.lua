local vec2 = {}

local meta = {}
meta.__index = meta

function vec2.new(x, y)
	local newVec = {
		x = x or 0,
		y = y or 0,
	}
	setmetatable(newVec, meta)

	return newVec
end

function meta:magnitude()
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function meta:normalized()
	return self / self:magnitude()
end

function meta.__eq(vec, otherVec)
	return vec.x == otherVec.x and vec.y == otherVec.y
end

function meta.__add(vec, otherVec)
	return vec2.new(vec.x + otherVec.x, vec.y + otherVec.y)
end

function meta.__sub(vec, otherVec)
	return vec2.new(vec.x - otherVec.x, vec.y - otherVec.y)
end

function meta.__mul(vec, scalar)
	assert(type(scalar) == "number")
	return vec2.new(vec.x * scalar, vec.y * scalar)
end

function meta.__div(vec, scalar)
	assert(type(scalar) == "number")
	return vec2.new(vec.x / scalar, vec.y / scalar)
end

function meta.__unm(vec)
	return vec2.new(-vec.x, -vec.y)
end

function meta.__tostring(vec)
	return string.format("(%s, %s)", vec.x, vec.y)
end

return vec2
