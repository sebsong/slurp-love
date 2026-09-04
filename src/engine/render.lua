---@class Renderable
---@field shouldDraw boolean
---@field setShader fun()?
---
---@field draw fun(self: Renderable, transform: love.Transform?)
---@field getZIndex fun(self: Renderable): number

---@class Render
local Render = {}

---@param items any
---@param getRenderable fun(item: any): Renderable
function Render.zSort(items, getRenderable)
    table.sort(items, function(item, otherItem)
        return getRenderable(item):getZIndex() < getRenderable(otherItem):getZIndex()
    end)
end

---@param renderable Renderable
---@param transform love.Transform?
---@param drawFn fun(renderable: Renderable)
function Render.draw(renderable, transform, drawFn)
    if not renderable.shouldDraw then
        return
    end

    love.graphics.push()
    if transform then
        love.graphics.applyTransform(transform)
    end

    if renderable.setShader then
        renderable.setShader()
    else
        love.graphics.setShader()
    end

    drawFn(renderable)

    love.graphics.pop()
end

return Render
