local steam_exists, steam = pcall(require, "steam")
local keyboard = lstg.Input.Keyboard
local mouse = lstg.Input.Mouse

--Just making sure steam api is accessible. Cuz "steam" require always is true for some reason. Just a double check.
if steam_exists then
    local res = steam.SteamInput ~= nil
    if not res then
        steam_exists = false
    end
end

---@class core.input
local M = {}

---@type table<string, boolean>
local keyState = {}
---@type table<string, boolean>
local keyStatePrev = {}
---@type table<string, integer>
local keyDirectionTimer = {}

local DIRECTION_KEYS = { "Up", "Down", "Left", "Right" }

---Performs the input state update. Should be called once per frame.
function M:refresh()
    for action, keycode in pairs(core.userdata.settings.keys) do
        local is_down = keyboard.GetKeyState(keycode)
        keyStatePrev[action] = keyState[action] or false
        keyState[action] = is_down

        if keyStatePrev[action] ~= is_down then
            core.signals:Emit("KeyStateChanged", action, is_down)
        end
    end

    for _, dir in ipairs(DIRECTION_KEYS) do
        if keyState[dir] then
            keyDirectionTimer[dir] = (keyDirectionTimer[dir] or 0) + 1
        else
            keyDirectionTimer[dir] = 0
        end
    end
end

---Returns `true` while the key is pressed down.
---@param action string e.g. "Shoot"
---@return boolean is_down
function M:is_down(action)
    return keyState[action] or false
end

---Returns true only on the first frame the key is pressed.
---@param action string e.g. "Shoot"
---@return boolean is_pressed
function M:is_pressed(action)
    return keyState[action] and not keyStatePrev[action] or false
end

---Returns true only on the first frame the key is released.
---@param action string e.g. "Shoot"
---@return boolean is_released
function M:is_released(action)
    return keyStatePrev[action] and not keyState[action] or false
end

---Returns how many consecutive frames the direction key has been held.
---@param dir "Up"|"Down"|"Left"|"Right"
---@return integer
function M:get_direction_timer(dir)
    return keyDirectionTimer[dir] or 0
end

---Converts a key action to a readable key name (e.g "Z" for Shoot).
---@param code number Key code to convert
---@return string key_name Human-readable key name
function M:key_to_name(code)
    if type(code) ~= "number" then
        return "Unknown"
    end
    if code == keyboard.None then
        return "-"
    end
    for k, v in pairs(keyboard) do
        if v == code then
            return k
        end
    end
    return ("KEY %d"):format(code)
end

local signals = require("core.foundation.signals")

signals:Register("KeyFrame", "FrameFunc", function()
    M:refresh()
end, signals.HIGH_PRIORITY, M)

return M