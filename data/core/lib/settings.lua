---@diagnostic disable-next-line: undefined-field
local keyboard = lstg.Input.Keyboard

---@alias KnownKeys
---| "Up"
---| "Down"
---| "Right"
---| "Left"
---| "Shoot"
---| "Bomb"
---| "Special"
---| "Focus"
---| "Retry"
---| "Snapshot"

---@class settings
local default_settings = {
    game = "",
    username = "Player",
    locale = "en-us",
    windowed = true,
    v_sync = true,
    audio_system = {
        preferred_endpoint_name = "",
        sound_effect_volume = 0.25,
        music_volume = 0.30
    },
    graphics_system = {
        preferred_device_name = "",
        fullscreen = false,
        vsync = true,
        width = 640,
        height = 480
    },
    keys = {
        Up = keyboard.Up,
        Down = keyboard.Down,
        Right = keyboard.Right,
        Left = keyboard.Left,
        Shoot = keyboard.Z,
        Bomb = keyboard.X,
        Special = keyboard.C,
        Focus = keyboard.LeftShift,
        Retry = keyboard.R,
        Snapshot = keyboard.Home,
    }
}

local function get_settings_file()
    return core.userdata.get_root_directory() .. "/settings.json"
end

local function apply_defaults(target, defaults)
    for k, v in pairs(defaults) do
        if target[k] == nil then
            target[k] = v
        elseif type(v) == "table" and type(target[k]) == "table" then
            apply_defaults(target[k], v)
        end
    end
end

function core.userdata.load_settings()
    local f, msg = io.open(get_settings_file(), 'r')
    if f then
        ---@type settings
        core.userdata.settings = json.deserialize(f:read("*a"))
        f:close()
        apply_defaults(core.userdata.settings, default_settings)
    else
        ---@type settings
        core.userdata.settings = default_settings
    end
end

function core.userdata.save_settings()
    local f, msg = io.open(get_settings_file(), 'w')
    if f then
        f:write(string.json_pretty(json.serialize(core.userdata.settings)))
        f:close()
    else
        error(msg)
    end
end

core.userdata.load_settings()
core.userdata.save_settings()