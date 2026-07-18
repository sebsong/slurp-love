local button = {}
local ui = {
	align = {
		CENTER = 1,
		LEFT = 2,
		RIGHT = 3,
		TOP = 4,
		BOTTOM = 5,
	},
	button,
}

local settings = require("engine/settings")

function ui.newAlignedTransform(width, height, horizontalAlign, verticalAlign, xPadding, yPadding)
	local x, y
	width, height = width or 0, height or 0
	local xOffset, yOffset = xPadding or 0, yPadding or 0

	if horizontalAlign == ui.align.LEFT then
		x = 0
	elseif horizontalAlign == ui.align.CENTER then
		x = settings.canvasPixelWidth / 2 - width / 2
	elseif horizontalAlign == ui.align.RIGHT then
		x = settings.canvasPixelWidth - width
		xOffset = -xOffset
	else
		error(("invalid align option: %d"):format(horizontalAlign))
	end

	if verticalAlign == ui.align.TOP then
		y = 0
	elseif verticalAlign == ui.align.CENTER then
		y = settings.canvasPixelHeight / 2 - height / 2
	elseif verticalAlign == ui.align.BOTTOM then
		y = settings.canvasPixelHeight - height
		yOffset = -yOffset
	else
		error(("invalid align option: %d"):format(verticalAlign))
	end

	return love.math.newTransform(x + xOffset, y + yOffset)
end

local function enable(self)
	self.enabled = true
end

local function disable(self)
	self.enabled = false
end

function button.new(
	onPress
)
	return {
		isPressed = false,
		wasPressedByMouse = false,
		isHovered = false,
		enabled = true,

		onPress,

		enable,
		disable
	}
end

return ui
