local Math = require("engine.math")
local Vec2 = require("engine.vec2")

---@class Collision
local Collision = {}

---@class Collider
---@field width integer
---@field height integer

---@class Collidable
---@field position Vec2?
---@field getPosition fun(self: Collidable): Vec2?
---@field collider Collider
---@field collidingWith Set
---@field onCollision fun(self: Collidable, otherCollidable: Collidable)

---@param x number
---@param y number
---@param collider Collider
---@param transform love.Transform
---@return boolean
function Collision.hitTest(x, y, collider, transform)
    local colliderX, colliderY = transform:transformPoint(0, 0)
    local xMin, xMax = colliderX, colliderX + collider.width
    local yMin, yMax = colliderY, colliderY + collider.height

    return x >= xMin and x < xMax and y >= yMin and y < yMax
end

local function getCollidablePosition(collidable)
    if collidable.position then
        return collidable.position
    elseif collidable.getPosition then
        return collidable:getPosition()
    else
        error("Collidable must have a position")
    end
end

local function getRectExtents(x, y, halfWidth, halfHeight)
    return (x - halfWidth), (x + halfWidth), (y - halfHeight), (y + halfHeight)
end

---@param collidable Collidable
---@param collidables Collidable[]
---@param targetPositionUpdate Vec2
---@return Vec2
function Collision.getPositionUpdate(collidable, collidables, targetPositionUpdate)
    local positionUpdate = targetPositionUpdate
    local position = getCollidablePosition(collidable)
    local collider = collidable.collider
    local halfWidth, halfHeight = collider.width / 2, collider.height / 2

    for _, otherCollidable in ipairs(collidables) do
        if collidable == otherCollidable then
            goto continue
        end

        local targetPosition = position + positionUpdate

        local otherPosition = getCollidablePosition(otherCollidable)
        local otherCollider = otherCollidable.collider

        local otherHalfWidth, otherHalfHeight = otherCollider.width / 2, otherCollider.height / 2

        local targetLeftX, targetRightX, targetTopY, targetBottomY =
            getRectExtents(targetPosition.x, targetPosition.y, halfWidth, halfHeight)
        local otherLeftX, otherRightX, otherTopY, otherBottomY =
            getRectExtents(otherPosition.x, otherPosition.y, otherHalfWidth, otherHalfHeight)

        local isLeft = targetPosition.x < otherPosition.x
        local xIntersects
        if isLeft then
            xIntersects = targetRightX >= otherLeftX
        else
            xIntersects = targetLeftX <= otherRightX
        end

        local isAbove = targetPosition.y < otherPosition.y
        local yIntersects
        if isAbove then
            yIntersects = targetBottomY >= otherTopY
        else
            yIntersects = targetTopY <= otherBottomY
        end

        if xIntersects and yIntersects then
            local xCorrection = Math.absMin(otherLeftX - targetRightX, otherRightX - targetLeftX)
            local yCorrection = Math.absMin(otherTopY - targetBottomY, otherBottomY - targetTopY)

            if math.abs(xCorrection) <= math.abs(yCorrection) then
                positionUpdate.x = positionUpdate.x + xCorrection
            else
                positionUpdate.y = positionUpdate.y + yCorrection
            end

            if collidable.onCollision and not collidable.collidingWith:contains(otherCollidable) then
                collidable:onCollision(otherCollidable)
            end
            if otherCollidable.onCollision and not otherCollidable.collidingWith:contains(collidable) then
                otherCollidable:onCollision(collidable)
            end

            collidable.collidingWith:insert(otherCollidable)
            otherCollidable.collidingWith:insert(collidable)
        else
            collidable.collidingWith:remove(otherCollidable)
            otherCollidable.collidingWith:remove(collidable)
        end

        ::continue::
    end

    return positionUpdate
end

---@param tilemap Tilemap
---@param layerIndex integer
function Collision.debugDrawTileColliders(tilemap, layerIndex)
    love.graphics.push()
    love.graphics.applyTransform(tilemap.tilemapIndexToWorldTransform)
    for rowIdx, row in ipairs(tilemap.layers[layerIndex].tiles) do
        for colIdx, tile in ipairs(row) do
            if tile.tileId then
                Collision.debugDrawCollider({ width = 1, height = 1 }, Vec2.new(colIdx, rowIdx))
            end
        end
    end
    love.graphics.pop()
end

---@param collider Collider
---@param position Vec2
function Collision.debugDrawCollider(collider, position)
    local x, y = unpack(position)
    local width, height = collider.width, collider.height
    local colliderVertices = {
        x - width / 2,
        y - height / 2,
        x + width / 2,
        y - height / 2,
        x + width / 2,
        y + height / 2,
        x - width / 2,
        y + height / 2,
    }

    love.graphics.polygon("line", unpack(colliderVertices))
end

return Collision
