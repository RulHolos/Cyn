local keyboard = lstg.Input.Keyboard
local mouse = lstg.Input.Mouse

---@class cyn.menu.config
cfg = {
    ---@type boolean If true, mouse control will be enabled for the entire menu.
    use_mouse = false,
    ---@type lstg.Color The color of the text for normal options.
    colorNormal = lstg.Color(255, 233, 207, 179),
    ---@type lstg.Color The color of the text for locked options.
    colorInvalid = lstg.Color(255, 148, 97, 45),
    ---@type lstg.Color The color of the text for when an option is selected.
    colorSelect = lstg.Color(255, 255, 255, 255),

    fade_time = 30, -- frames for enter/exit fade tweens
    fade_ease = "inOutCubic",

    layer_step = 1, -- layer gap between a node and each of its children
    base_layer_offset = 9, -- layer gap between LAYER_TOP and a root node

    confirm_key = "shoot",
    click_mouse_button = "Left",

    exit_key = "spell",
    exit_mouse_button = "Right",
}

return cfg
