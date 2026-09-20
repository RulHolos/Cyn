local signals = require("cyn.foundation.signals")
local settings = require("cyn.foundation.settings_manager")
local screen = require("cyn.engine.viewport.screen")
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

---@class cyn.input
local M = {}

---@type table<string, boolean>
local keyState = {}
---@type table<string, boolean>
local mouseState = {}
---@type table<string, boolean>
local keyStatePrev = {}
---@type table<string, boolean>
local mouseStatePrev = {}
---@type table<string, integer>
local keyDirectionTimer = {}

local inputMouse = {
    Left = 1,
    Middle = 4,
    Right = 2,
}

local DIRECTION_KEYS = { "Up", "Down", "Left", "Right" }

---Performs the input state update. Should be called once per frame.
function M:refresh()
    for action, keycode in pairs(settings:get().keys) do
        local is_down = keyboard.GetKeyState(keycode)
        keyStatePrev[action] = keyState[action] or false
        keyState[action] = is_down

        if keyStatePrev[action] ~= is_down then
            signals:Emit("KeyStateChanged", action, is_down)
        end
    end

    for action, keycode in pairs(inputMouse) do
        local is_down = mouse.GetKeyState(keycode)
        mouseStatePrev[action] = mouseState[action] or false
        mouseState[action] = is_down

        if mouseStatePrev[action] ~= is_down then
            signals:Emit("MouseStateChanged", action, is_down)
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

---@param key "Left"|"Middle"|"Right"
---@return boolean is_pressed
function M:mouse_is_pressed(key)
    return mouseState[key] and (not mouseStatePrev[key]) or false
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

---Returns the mouse position normalized to the current viewport ([0, screen.width], [0, screen.height])
---@return number x, number y Coordinates in UI space
---@return number norm_x, number norm_y Normalized viewport position [0, 1]
function M:get_normalized_mouse_position()
    local mx, my = lstg.GetMousePosition()

    local vp_l = screen.dx
    local vp_r = screen.width * screen.scale + screen.dx
    local vp_b = screen.dy
    local vp_t = screen.height * screen.scale + screen.dy

    local norm_x = (mx - vp_l) / (vp_r - vp_l)
    local norm_y = (my - vp_b) / (vp_t - vp_b)

    local ui_x = norm_x * screen.width
    local ui_y = norm_y * screen.height

    return ui_x, ui_y, norm_x, norm_y
end

signals:Register("KeyFrame", "FrameFunc", function()
    M:refresh()
end, signals.HIGH_PRIORITY, M)

return M