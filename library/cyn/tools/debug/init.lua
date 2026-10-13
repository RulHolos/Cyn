local imgui_exists, imgui = pcall(require, "imgui")
if not imgui_exists then
    lstg.Log(LOG.ERROR, "!! ImGui was invoked but doesn't exist !! (literally, how did you manage that)")
end
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
local F3_Trigger = KeyDownTrigger(Keyboard.F3)

local patch = "library.cyn.tools.debug.views."
local path = "library/cyn/tools/debug/views/"

---@param view cyn.debug.view
local function layoutViewmenuItem(view)
    local enabled = view:getEnabled()
    if ImGui.MenuItem(view:getWindowName(), nil, enabled) then
        enabled = not enabled
    end
    view:setState(enabled)
end

---@param view cyn.debug.view
local function layoutView(view)
    local enabled = view:getEnabled()
    if not enabled then
        return
    end

    local show, enabled = ImGui.Begin(view:getWindowName(), enabled)
    if enabled ~= nil then
        view:setState(enabled)
    end
    if show then
        view:layout()
    end
    ImGui.End()
end

---@class cyn.debug.menu_node
---@field children cyn.debug.menu_node[]
---@field by_name table<string, cyn.debug.menu_node>
---@field entries { id: string, layout: fun() }[]
---@field name string

---@return cyn.debug.menu_node
local function newNode(name)
    return { name = name, children = {}, by_name = {}, entries = {} }
end

---@param node cyn.debug.menu_node
local function layoutNode(node)
    for _, e in ipairs(node.entries) do
        e.layout()
    end
    for _, child in ipairs(node.children) do
        if ImGui.BeginMenu(child.name) then
            layoutNode(child)
            ImGui.EndMenu()
        end
    end
end

---@class cyn.debug.manager
local M = {
    ---@type cyn.debug.menu_node Root of menus registered through addMenu.
    menu_root = newNode(""),
    ---@type table<string, cyn.debug.view>
    view_collection = {},
    ---@type boolean
    show_menu = false,
    ---@type table<string, string> module name -> last known view id, tracks what loadViews has already registered
    loaded_modules = {}
}
Cyn.imgui_manager = M

---@param view cyn.debug.view
function M:addView(view)
    table.insert(self.view_collection, { view:getViewId(), view })
    self:addMenu("view:" .. view:getViewId(), view:getMenuGroup(), function()
        layoutViewmenuItem(view)
    end)
end

---@param view_id string Id of the view to remove.
function M:removeView(view_id)
    for i, v in ipairs(self.view_collection) do
        if v[1] == view_id then
            table.remove(self.view_collection, i)
            self:removeMenu("view:" .. view_id)
            break
        end
    end
end

---@param folder_path string? Directory to scan. Defaults to the built-in views folder.
---@param module_patch string? Dotted require prefix matching folder_path. Defaults to the built-in views folder.
function M:loadViews(folder_path, module_patch)
    folder_path = folder_path or path
    module_patch = module_patch or patch

    local files = lstg.FileManager.EnumFiles(folder_path, "lua")

    for _, v in ipairs(files) do
        local file = string.sub(v[1], string.len(folder_path) + 1, string.len(v[1]) - 4)
        local module_name = module_patch .. file
        local previous_id = self.loaded_modules[module_name]

        if previous_id then
            self:removeView(previous_id)
        end

        package.loaded[module_name] = nil
        local view = require(module_name)

        if type(view) == "table" and view.getViewId then
            lstg.Log(LOG.INFO, "Adding debug view from file: " .. file)
            self:addView(view)
            self.loaded_modules[module_name] = view:getViewId()
        else
            self.loaded_modules[module_name] = nil
        end
    end
end

---Registers content inside a main menu bar independently of any other debug views.
---
---`path` can be nested, in that case use a `/` to separate the levels (e.g. "Yeva/Tools")
---@param id string
---@param path string|string[]
---@param layout fun()
function M:addMenu(id, path, layout)
    self:removeMenu(id)

    if type(path) == "string" then
        local parts = {}
        for part in path:gmatch("[^/]+") do
            table.insert(parts, part)
        end
        path = parts
    end
    assert(#path > 0, "menu path can't be empty")

    local node = self.menu_root
    for _, name in ipairs(path) do
        local child = node.by_name[name]
        if not child then
            child = newNode(name)
            node.by_name[name] = child
            table.insert(node.children, child)
        end
        node = child
    end
    table.insert(node.entries, { id = id, layout = layout })
end

---@param id string
function M:removeMenu(id)
    local function strip(node)
        for i = #node.entries, 1, -1 do
            if node.entries[i].id == id then
                table.remove(node.entries, i)
            end
        end
        for i = #node.children, 1, -1 do
            local child = node.children[i]
            strip(child)
            if #child.entries == 0 and #child.children == 0 then
                table.remove(node.children, i)
                node.by_name[child.name] = nil
            end
        end
    end
    strip(self.menu_root)
end

function M:frame()
    if not imgui_exists then
        return
    end

    for _, v in ipairs(self.view_collection) do
        v[2]:frame()
    end
end

local b_show_demo_window = false
local b_show_memuse_window = false
local b_show_framept_window = false
local b_show_testinput_window = false
local b_show_resmgr_window = false

function M:layout()
    if not DEBUG then
        return
    end

    if F3_Trigger() then
        self.show_menu = not self.show_menu
    end

    if not imgui_exists then
        return
    end

    if self.show_menu then
        if ImGui.BeginMainMenuBar() then
            for _, root in ipairs(self.menu_root.children) do
                if ImGui.BeginMenu(root.name) then
                    layoutNode(root)
                    ImGui.EndMenu()
                end
            end

            -- I can't do that another way. Sub is stupid and I don't want to only support Flux just because of that.
            if imgui.ImGui.BeginMenu("Backend") then
                if imgui.ImGui.MenuItem("Memory Usage", nil, b_show_memuse_window) then b_show_memuse_window = not b_show_memuse_window end
                if imgui.ImGui.MenuItem("Frame Statistics", nil, b_show_framept_window) then b_show_framept_window = not b_show_framept_window end
                if imgui.ImGui.MenuItem("Test Input", nil, b_show_testinput_window) then b_show_testinput_window = not b_show_testinput_window end
                if imgui.ImGui.MenuItem("Resource Manager", nil, b_show_resmgr_window) then b_show_resmgr_window = not b_show_resmgr_window end
                if imgui.ImGui.MenuItem("Demo", nil, b_show_demo_window) then b_show_demo_window = not b_show_demo_window end
                imgui.ImGui.EndMenu()
            end

            ImGui.EndMainMenuBar()
        end

        if b_show_demo_window then
            b_show_demo_window = imgui.ImGui.ShowDemoWindow(b_show_demo_window) or false
        end
        if b_show_memuse_window and imgui.backend.ShowMemoryUsageWindow then
            b_show_memuse_window = imgui.backend.ShowMemoryUsageWindow(b_show_memuse_window) or false
        end
        if b_show_framept_window and imgui.backend.ShowFrameStatistics then
            b_show_framept_window = imgui.backend.ShowFrameStatistics(b_show_framept_window) or false
        end

        if b_show_testinput_window and imgui.backend.ShowTestInputWindow then
            b_show_testinput_window = imgui.backend.ShowTestInputWindow(b_show_testinput_window) or false
        end

        if b_show_resmgr_window and imgui.backend.ShowResourceManagerDebugWindow then
            b_show_resmgr_window = imgui.backend.ShowResourceManagerDebugWindow(b_show_resmgr_window) or false
        end

        for _, v in ipairs(self.view_collection) do
            layoutView(v[2])
        end
    end
end

function M:isActive()
    return self.show_menu
end

M:loadViews("library/cyn/tools/debug/views/", "library.cyn.tools.debug.views.")

---- View Definition ----
---@class cyn.debug.view
local V = {
    enabled = false,
}

function V:getWindowName() return "View" end
function V:getMenuGroup() return "Tool" end
function V:getViewId() return "view.default" end
function V:getEnabled() return self.enabled end
---@param enable boolean
function V:setState(enable) self.enabled = enable end
function V:frame() end
function V:layout() end

require("cyn.tools.imgui_host"):register("debug", M, 10)

return M