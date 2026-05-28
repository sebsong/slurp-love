local vec2 = {}

local meta = {}

function vec2.new(x, y)
	local newVec = { x or 0, y or 0 }
	setmetatable(newVec, meta)

	return newVec
end

function meta:magnitude()
	return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function meta:normalized()
	local magnitude = self:magnitude()
	if magnitude == 0 then
		return self
	end

	return self / self:magnitude()
end

function meta.__index(vec, key)
	if key == "x" then
		return vec[1]
	elseif key == "y" then
		return vec[2]
	end

	return meta[key]
end

function meta.__newindex(vec, key, val)
	if key == "x" then
		vec[1] = val
		return
	elseif key == "y" then
		vec[2] = val
		return
	end

	rawset(vec, key, val)
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
