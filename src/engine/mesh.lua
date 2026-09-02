local Render = require("engine.render")

---@class Mesh: Renderable
---@field mesh love.Mesh
---@field numInstances integer
---@field xOffset integer
---@field yOffset integer
---@field zIndex number
---@field zIndexOffset number
---@field setShader fun()?
local Mesh = {}
Mesh.__index = Mesh

local NUM_VERTICES_PER_INSTANCE = 6

---comment
---@param vertices table
---@param image love.Image
---@param quad love.Quad
---@param position Vec2
local function insertQuadVertices(vertices, image, quad, position)
    local imageWidth, imageHeight = image:getDimensions()
    local quadX, quadY, quadWidth, quadHeight = quad:getViewport()

    local x0, y0 = unpack(position)
    local x1, y1 = x0 + quadWidth, y0 + quadHeight

    local u0, v0 = quadX / imageWidth, quadY / imageHeight
    local u1, v1 = u0 + quadWidth / imageWidth, v0 + quadHeight / imageHeight

    table.insert(vertices, { x0, y0, u0, v0 })
    table.insert(vertices, { x0, y1, u0, v1 })
    table.insert(vertices, { x1, y0, u1, v0 })

    table.insert(vertices, { x1, y0, u1, v0 })
    table.insert(vertices, { x0, y1, u0, v1 })
    table.insert(vertices, { x1, y1, u1, v1 })
end

---comment
---@param image love.Image
---@param quads love.Quad[]
---@param positions Vec2[]
---@param vertexFormat table?
---@param usage love.SpriteBatchUsage
---@param xOffset integer?
---@param yOffset integer?
---@param zIndex number?
---@param zIndexOffset number?
---@return Mesh
function Mesh.new(image, quads, positions, vertexFormat, usage, xOffset, yOffset, zIndex, zIndexOffset)
    assert(#quads == #positions)

    local numInstances = #quads

    local vertices = {}
    for i = 1, numInstances do
        insertQuadVertices(vertices, image, quads[i], positions[i])
    end

    local _mesh
    if vertexFormat then
        _mesh = love.graphics.newMesh(vertexFormat, vertices, "triangles", usage)
    else
        _mesh = love.graphics.newMesh(vertices, "triangles", usage)
    end

    _mesh:setTexture(image)

    ---@type Mesh
    local mesh = {
        shouldDraw = true,
        mesh = _mesh,
        numInstances = numInstances,
        xOffset = xOffset or 0,
        yOffset = yOffset or 0,
        zIndex = zIndex or 0,
        zIndexOffset = zIndexOffset or 0,
        setShader = nil,
    }

    setmetatable(mesh, Mesh)

    return mesh
end

---@return number
function Mesh:getZIndex()
    return self.zIndex + self.zIndexOffset
end

---@param mesh Mesh
local function draw(mesh)
    love.graphics.drawInstanced(mesh.mesh, mesh.numInstances, mesh.xOffset, mesh.yOffset)
end

---@param transform love.Transform?
function Mesh:draw(transform)
    Render.draw(self, transform, draw)
end

return Mesh
