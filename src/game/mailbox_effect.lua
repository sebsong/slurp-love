local packageEffect = {}

local color = require("engine/color")

local OUTLINE_COLOR_IDX = 7
local SHADER_FILE_PATH = "assets/shader/outline.glsl"

local shader
local deliveryMailbox

function packageEffect.load()
	shader = love.graphics.newShader(SHADER_FILE_PATH)

	shader:send("OUTLINE_COLOR", color.palette[OUTLINE_COLOR_IDX])
end

function packageEffect.update(boat, mailboxes)
	deliveryMailbox = boat:getDeliveryMailbox(mailboxes)
end

function packageEffect.setShader(mailbox)
	shader:send("showOutline", mailbox == deliveryMailbox)
	love.graphics.setShader(shader)
end

return packageEffect
