if not package.loaded["yeva.db.userdata"] then
    error("`yeva.db.userdata` must be loaded before `yeva.db.settings`")
end

local keyboard = lstg.Input.Keyboard
local signals = require("cyn.foundation.signals")
local userdata_manager = require("cyn.foundation.userdata_manager")

---@alias KnownKeys
---| "up"
---| "down"
---| "right"
---| "left"
---| "shoot"
---| "bomb"
---| "special"
---| "focus"
---| "retry"
---| "snapshot"

---@class yeva.db.default_settings
local default_settings = {
    game = "",
    username = "Player",
    locale = "en",
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
    ---@type table<KnownKeys, number>
    keys = {
        up = keyboard.Up,
        down = keyboard.Down,
        right = keyboard.Right,
        left = keyboard.Left,
        shoot = keyboard.Z,
        bomb = keyboard.X,
        special = keyboard.C,
        focus = keyboard.LeftShift,
        retry = keyboard.R,
        snapshot = keyboard.Home,
    }
}

local function get_settings_file()
    return userdata_manager.userdata.get_root_directory() .. "/settings.json"
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

---@class yeva.db.settings : cyn.ISettings, yeva.db.default_settings
local M = {}

---@return yeva.db.settings
function M.load()
    local f, msg = io.open(get_settings_file(), 'r')
    ---@type yeva.db.settings
    local settings = nil
    if f then
        settings = json.deserialize(f:read("*a")) --[[@as yeva.db.settings]]
        f:close()
        apply_defaults(settings, default_settings)
        signals:Emit(signals.known_signals.SettingsLoaded)
    else
        settings = MakeInstance(default_settings) --[[@as yeva.db.settings]]
        lstg.Log(LOG.WARN, "Settings file not found, using default settings.")
        if msg then
            lstg.Log(LOG.WARN, msg)
        end
    end
    return setmetatable(settings, { __index = M })
end

function M:save()
    local f, msg = io.open(get_settings_file(), 'w')
    if f then
        f:write(string.json_pretty(json.serialize(self)))
        f:close()
        signals:Emit(signals.known_signals.SettingsSaved)
    else
        error(msg)
    end
end

local settings_manager = require("cyn.foundation.settings_manager")
settings_manager:set_settings_class(M)

return M