local PackageEffect = {}

local Color = require("engine/color")

local OUTLINE_COLOR_IDX = 7
local SHADER_FILE_PATH = "assets/shader/outline.glsl"

local shader
local deliveryMailbox

function PackageEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader:send("OUTLINE_COLOR", Color.palette[OUTLINE_COLOR_IDX])
end

function PackageEffect.update(boat, mailboxes)
	deliveryMailbox = boat:getDeliveryMailbox(mailboxes)
end

function PackageEffect.setShader(mailbox)
	shader:send("showOutline", mailbox == deliveryMailbox)
	love.graphics.setShader(shader)
end

return PackageEffect
