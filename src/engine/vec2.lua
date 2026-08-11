---@class Vec2
---@field [1] any
---@field [2] any
---@field x any
---@field y any
---@
---@field magnitude fun(self: Vec2): number
---@field distanceTo fun(self: Vec2, otherVec: Vec2): number
---@field normalized fun(self: Vec2): Vec2
local Vec2 = {}
Vec2.__index = Vec2

function Vec2.new(x, y)
    local newVec = { x or 0, y or 0 }
    setmetatable(newVec, Vec2)

    return newVec
end

function Vec2.__index(vec, key)
    if key == "x" then
        return vec[1]
    elseif key == "y" then
        return vec[2]
    end

    return Vec2[key]
end

function Vec2.__newindex(vec, key, val)
    if key == "x" then
        vec[1] = val
        return
    elseif key == "y" then
        vec[2] = val
        return
    end

    rawset(vec, key, val)
end

function Vec2:magnitude()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vec2:distanceTo(otherVec)
    return (otherVec - self):magnitude()
end

function Vec2:normalized()
    local magnitude = self:magnitude()
    if magnitude == 0 then
        return self
    end

    return self / self:magnitude()
end

function Vec2.__eq(vec, otherVec)
    return vec.x == otherVec.x and vec.y == otherVec.y
end

function Vec2.__add(vec, otherVec)
    return Vec2.new(vec.x + otherVec.x, vec.y + otherVec.y)
end

function Vec2.__sub(vec, otherVec)
    return Vec2.new(vec.x - otherVec.x, vec.y - otherVec.y)
end

function Vec2.__mul(vec, scalar)
    assert(type(scalar) == "number")
    return Vec2.new(vec.x * scalar, vec.y * scalar)
end

function Vec2.__div(vec, scalar)
    assert(type(scalar) == "number")
    return Vec2.new(vec.x / scalar, vec.y / scalar)
end

function Vec2.__unm(vec)
    return Vec2.new(-vec.x, -vec.y)
end

function Vec2.__tostring(vec)
    return string.format("(%s, %s)", vec.x, vec.y)
end

return Vec2
