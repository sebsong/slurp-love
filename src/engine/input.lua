local Set = require("engine/set")

local Input = {
	MODIFIER_KEYS = Set.new(
		"numlock",
		"capslock",
		"scrolllock",
		"rshift",
		"lshift",
		"rctrl",
		"lctrl",
		"ralt",
		"lalt",
		"rgui",
		"lgui",
		"mode"
	)
}

return Input
