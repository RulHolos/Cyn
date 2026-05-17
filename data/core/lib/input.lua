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
M.__index = M
core.input = M

---@type table<string, table<string, boolean>>
local keyState = {}
---@type table<string, table<string, boolean>>
local keyStatePrev = {}
---@type table<string, table<string, integer>>
local keyDirectionTimer = {}

local DIRECTION_KEYS = { "Up", "Down", "Left", "Right" }

---Performs the input state update. Should be called once per frame.
function M:refresh()
    for player, bindings in pairs(core.userdata.settings.keys) do
        if not keyState[player] then
            keyState[player] = {}
            keyStatePrev[player] = {}
            keyDirectionTimer[player] = {}
            for _, dir in ipairs(DIRECTION_KEYS) do
                keyDirectionTimer[player][dir] = 0
            end
        end

        for action, keycode in pairs(bindings) do
            local is_down = keyboard.GetKeyState(keycode)
            keyStatePrev[player][action] = keyState[player][action] or false
            keyState[player][action] = is_down

            if keyStatePrev[player][action] ~= is_down then
                core.signals:Emit("KeyStateChanged", player, action, is_down)
            end
        end

        for dir, _ in pairs(keyDirectionTimer[player]) do
            if keyState[player][dir] then
                keyDirectionTimer[player][dir] = keyDirectionTimer[player][dir] + 1
            else
                keyDirectionTimer[player][dir] = 0
            end
        end
    end
end

---Returns `true` while the key is pressed down.
---@param player string e.g. "p1"
---@param action string e.g. "Shoot"
---@return boolean is_down
function M:is_down(player, action)
    return keyState[player] and keyState[player][action] or false
end

---Returns true only on the first frame the key is pressed.
---@param player string e.g. "p1"
---@param action string e.g. "Shoot"
---@return boolean is_pressed
function M:is_pressed(player, action)
    if not keyState[player] then return false end
    return keyState[player][action] and not keyStatePrev[player][action]
end

---Returns true only on the first frame the key is released.
---@param player string e.g. "p1"
---@param action string e.g. "Shoot"
---@return boolean is_released
function M:is_released(player, action)
    if not keyState[player] then return false end
    return keyStatePrev[player][action] and not keyState[player][action]
end

---Returns how many consecutive frames the direction key has been held.
---@param player string e.g. "p1"
---@param dir "Up"|"Down"|"Left"|"Right"
---@return integer
function M:get_direction_timer(player, dir)
    return keyDirectionTimer[player] and keyDirectionTimer[player][dir] or 0
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