--[[
Hi
You won't find much here, it's mainly the editor itself.

Yeah uh sorry but Nori isn't really modular, it's built for a purpose, the only modular part are the nodes and extensions.
]]

local bor = bit.bor
local DockNodeFlags = imgui.ImGuiDockNodeFlags
local imgui_exists, imgui = pcall(require, "imgui")
if not imgui_exists then
    lstg.Log(LOG.ERROR, "!! ImGui was invoked but doesn't exist !! (literally, how did you manage that)")
end
local cdf = require("cyn.presentation.cdf")

local ImGui = imgui.ImGui

---@param vkey number
---@return fun() : boolean
local function KeyDownTrigger(vkey)
    local last_state = false
    local state = false
    return function()
        state = lstg.GetKeyState(vkey)
        if not last_state and state then
            last_state = state
            return true
        else
            last_state = state
            return false
        end
    end
end

local Keyboard = lstg.Input.Keyboard
local F2_Trigger = KeyDownTrigger(Keyboard.F2)

---Represents a framework extension for Nori. Is loaded by default when the editor is initialized.
---
---This hosts a list of custom behaviors and "nodes".
---@class nori.extension

---@class nori.file
---@field path string
---@field data table

---@class nori.window
---@field parent nori.manager
---@field is_open boolean Whether the window is currently open.
---@field name string Name to identify the window with.
---@field init fun(self: nori.window)
---@field render fun(self: nori.window)

---Nori is an editor directly built on top of Cyn, it works with the Yeva and THlib frameworks for providing nodes.
---
---This editor is meant to be ONLY used for making patterns, bosses and spell-cards easily. It is not built for any other purpose.
---
---If you want to have a more powerful editor, you can use Sharp-X or LunaForge.
---
---To generate lua files, Nori takes advantage of running in the luajit vm directly and the CDF file system. It uses the parser AND the writer.
---@class nori.manager
local M = {
    show_editor = false,
    ---@private
    _initialized = false,

    ---@type "yeva"|nil
    using_framework = nil,

    ---@type nori.extension
    extension = nil,

    ---@type nori.window[]
    windows = {},

    ---@type nori.file[]
    open_files = {},
    selected_file_index = 1,

    ---@type nori.config
    config = {},
}

---Initializes the Nori editor's states and loads the Framework dependencies
---
---Warning: IS NOT CALLED AUTOMATICALLY. Call it yourself once.
function M:initialize()
    if self._initialized then
        return
    end

    if self.using_framework == nil then
        lstg.MsgBoxWarn("You must specify the library your game uses before being able to use Nori.")
        return
    end

    self:load_config()

    ---Wins

    self:add_window(require("nori.windows.main"))
    self:add_window(require("nori.windows.attributes"))

    ---Popups

    self:add_window(require("nori.popups.preferences"))

    ---

    for _, window in ipairs(self.windows) do
        if window.init then
            window:init()
        end
    end

    ---@type nori.extension
    self.extension = require(self.using_framework .. ".nori_ext")

    self._initialized = true
end

function M:add_window(window)
    window.parent = self
    table.insert(self.windows, window)
end

---@param name string Name of the window to find.
---@generic C : nori.window
---@return C|nil
function M:find_window_by_name(name)
    for _, window in ipairs(self.windows) do
        if window.name == name then
            return window
        end
    end
    return nil
end

function M:isActive()
    return self.show_editor == true
end

function M:layout()
    if not DEBUG or (not imgui_exists) then
        return
    end

    if not self._initialized then
        return
    end

    if F2_Trigger() then
        self.show_editor = not self.show_editor
    end

    if self.show_editor then
        ImGui.DockSpaceOverViewport(0, DockNodeFlags.PassthruCentralNode)
    else
        ImGui.DockSpaceOverViewport(0, bor(DockNodeFlags.KeepAliveOnly, DockNodeFlags.PassthruCentralNode))
    end

    self:editor_windows()
end

function M:editor_windows()
    if not self.show_editor then
        return
    end

    for _, window in ipairs(self.windows) do
        if window.render then
            window:render()
        end
    end
end

--#region Nori's Configuration

local config_path = "nori/config" --Working with CDF, so no extension, but it's "config.cdf" here

---@class nori.config
local default_config = {
    remember_open_files = false,

    ---@type string[] List of paths to files.
    last_opened_files = {},
}

local function strip_metadata(block)
    local out = {}
    for k, v in pairs(block) do
        if not (type(k) == "string" and k:sub(1, 1) == "_") then
            out[k] = type(v) == "table" and strip_metadata(v) or v
        end
    end
    return out
end

local function apply_defaults(target, defaults)
    for k, v in pairs(defaults) do
        if target[k] == nil then
            target[k] = type(v) == "table" and strip_metadata(v) or v
        elseif type(v) == "table" and type(target[k]) == "table" then
            apply_defaults(target[k], v)
        end
    end
end

local function to_block(tbl, is_root)
    local out = is_root and { _type = "Config", _name = "nori" } or { _type = "Section" }
    for k, v in pairs(tbl) do
        if type(v) == "table" and next(v) ~= nil and v[1] == nil and not v.__cdf_raw then
            out[k] = to_block(v)
        else
            out[k] = v
        end
    end
    return out
end

---Loads the Nori config from the cdf file. Creates it if it doesn't exist.
function M:load_config()
    local f = io.open(config_path .. ".cdf", "r")
    if not f then
        lstg.Log(LOG.WARN, "Nori config file not found, creating it with the default config.")
        self.config = strip_metadata(default_config)
        self:write_config()
        return
    end
    f:close()

    local file = cdf.load_file(config_path)
    local block = file.data[1]

    self.config = block and strip_metadata(block) or {}
    apply_defaults(self.config, default_config)
end

---Writes the configuration to the disk.
function M:write_config()
    local ok, err = cdf.writer.write_file(config_path, to_block(self.config or {}, true))
    if not ok then
        lstg.Log(LOG.ERROR, "Failed to write Nori config: " .. tostring(err))
        return
    end
    cdf.invalidate(config_path)
end

--#endregion

require("cyn.tools.imgui_host"):register("nori", M, 0)

return M