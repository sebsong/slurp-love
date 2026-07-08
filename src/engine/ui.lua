local button = {}
local ui = {
	align = {
		horizontal = {
			LEFT = 1,
			CENTER = 2,
			RIGHT = 3,
		},
		vertical = {
			TOP = 4,
			CENTER = 5,
			BOTTOM = 6,
		}
	},
	button,
}

local settings = require("engine/settings")

function ui.newAlignedTransform(image, horizontalAlign, verticalAlign, xOffset, yOffset)
	local x, y
	local width, height = image:getDimensions()

	if horizontalAlign == ui.align.horizontal.LEFT then
		x = 0
	elseif horizontalAlign == ui.align.horizontal.CENTER then
		x = settings.canvasPixelWidth / 2 - width / 2
	elseif horizontalAlign == ui.align.horizontal.RIGHT then
		x = settings.canvasPixelWidth - width
	else
		error(("invalid align option: %d"):format(horizontalAlign))
	end

	if verticalAlign == ui.align.vertical.TOP then
		y = 0
	elseif verticalAlign == ui.align.vertical.CENTER then
		y = settings.canvasPixelHeight / 2 - height / 2
	elseif verticalAlign == ui.align.vertical.BOTTOM then
		y = settings.canvasPixelHeight / 2 - height / 2
	else
		error(("invalid align option: %d"):format(verticalAlign))
	end

	return love.math.newTransform(x + (xOffset or 0), y + (yOffset or 0))
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
