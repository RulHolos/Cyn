local keyboard = lstg.Input.Keyboard

--#region Random-ass boilerplate

---@class cyn.ISettings
---@field load fun(): cyn.ISettings
---@field save fun(self: cyn.ISettings)
local ISettings = {}

---TODO: Change when the behavior is set.
---@class cyn.default_settings : cyn.ISettings
local default_settings = {
    game = "", --Optional.
    locale = "en",
    windowed = true,
    v_sync = true,
    audio_system = {
        sound_effect_volume = 0.25,
        music_volume = 0.30
    },
    graphics_system = {
        fullscreen = false,
        vsync = true,
        width = 640,
        height = 480
    },
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

---@alias cyn.active_settings cyn.default_settings

--#endregion

---Represents a proxy manager for settings access.
---@class cyn.settings_manager
local M = {
    ---@type cyn.active_settings
    settings = nil
}

--[[
Cyn's settings requires a few fields set. You cannot opt out of those if you use the default Cyn library with default THlib or Yeva frameworks.
It requires at least data formatted like the `cyn.default_settings` class.
```

If you modify Cyn, THlib or Yeva, you could change those variables.
audio_system and graphics_system are read by default by config.json at the very start of the engine's launch.
They are engine-defined variables, not library or framework defined.
]]

---Sets the settings instance.
---@generic T : cyn.ISettings
---@param settings_class T
---@return T
function M:set_settings_class(settings_class)
    assert(settings_class, "settings_class must not be nil")

    ---@cast settings_class cyn.ISettings
    self.settings = settings_class.load() --[[@as cyn.active_settings]]
    self.settings:save()

    return settings_class
end

---Shorthand for the settings instance.
---@return cyn.active_settings
function M:get()
    assert(self.settings, "settings instance is not set")

    return self.settings
end

return M