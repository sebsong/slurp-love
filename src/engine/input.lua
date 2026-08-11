local Set = require("engine.set")

---@class Input
---@field MODIFIER_KEYS Set
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
    ),
}

return Input
