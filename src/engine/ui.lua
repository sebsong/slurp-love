local button = {}
local ui = { button }

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
