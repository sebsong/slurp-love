local PackageEffect = {}

local Color = require("engine.color")

local SHADER_FILE_PATH = "assets/shader/outline.glsl"

local shader
local deliveryMailbox

function PackageEffect.load()
    shader = love.graphics.newShader(SHADER_FILE_PATH)

    shader:send("OUTLINE_COLOR", Color.palette[1])
    shader:send("HIGHLIGHT_COLOR", Color.palette[7])
end

function PackageEffect.update(boat, mailboxes)
    deliveryMailbox = boat:getDeliveryMailbox(mailboxes)
end

function PackageEffect.setShader(mailbox)
    shader:send("highlightOutline", mailbox == deliveryMailbox)
    love.graphics.setShader(shader)
end

return PackageEffect
