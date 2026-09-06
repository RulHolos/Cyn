-- ============ --
-- UI Manager   --
-- ============ --

------------------------------------------------------------
--- Widget base

---@class core.ui.widget
---@field name string
---@field x number
---@field y number
---@field rot number
---@field scale_h number
---@field scale_v number
---@field order integer Rendering order: lower = drawn first (behind).
---@field visible boolean If true, render skipped
---@field active boolean If true, frame skipped
---@field data table
---@field init fun(self: core.ui.widget)?
---@field frame fun(self: core.ui.widget)?
---@field render fun(self: core.ui.widget)?
---@field del fun(self: core.ui.widget)? Optional cleanup function called when the widget is removed.
local _widget_base = {
    name = "",
    x = 0,
    y = 0,
    rot = 0,
    scale_h = 1,
    scale_v = 1,
    order = 0,
    visible = true,
    active = true,
    data = {},
    timer = 0,
    init = function(self) end,
    frame = function(self) end,
    render = function(self) end,
    del = function(self) end,
}
_widget_base.__index = _widget_base

---@param name string
---@param overrides table?
---@return core.ui.widget
local function new_widget(name, overrides)
    local w = setmetatable({}, _widget_base)
    w.name = name
    w.data = {}
    if overrides then
        for k, v in pairs(overrides) do
            w[k] = v
        end
    end
    return w
end

------------------------------------------------------------
--- Sorted insertion (ascending order: lower order value = drawn first)

---@param list core.ui.widget[]
---@param w core.ui.widget
local function _sortedInsert(list, w)
    local n = #list
    if n == 0 or w.order >= list[n].order then
        list[n + 1] = w
        return
    end
    for i = 1, n do
        if list[i].order > w.order then
            table.insert(list, i, w)
            return
        end
    end
    list[n + 1] = w
end

------------------------------------------------------------
--- UI Manager

---@class core.ui_manager
---@field _widgets core.ui.widget[]
---@field _by_name table<string, core.ui.widget>
---@field _defs table<string, table>
---@field _def_order string[]
local M = {
    _widgets = {},
    _by_name = {},
    _defs = {},
    _def_order = {},
}
core.ui_manager = M
---@return core.ui.widget
function M.widget()
    return new_widget("", nil)
end

---@param name string
---@param overrides table?
---@return core.ui.widget
function M:_instantiate_widget(name, overrides)
    assert(not self._by_name[name], ("UI Manager: a widget named '%s' already exists."):format(name))

    local w = new_widget(name, overrides)
    _sortedInsert(self._widgets, w)
    self._by_name[name] = w
    if w.init then w:init() end
    return w
end

---Registers a widget definition. Fresh widget instances are created on every stage start.
---@param name string Unique name for the widget.
---@param overrides table? Optional fields to override (x, y, rot, scale_h, scale_v, order, visible, active, data, init, frame, render).
function M:register_widget(name, overrides)
    assert(type(name) == "string" and name ~= "", "UI Manager: widget name must be a non-empty string.")

    if not self._defs[name] then
        table.insert(self._def_order, name)
    end
    self._defs[name] = overrides

    local live = self._by_name[name]
    if live then
        local ambient_pool = lstg.GetResourceStatus()
        resources.SetActivePool("stage")

        if live.del then live:del() end
        for k in pairs(live) do
            live[k] = nil
        end

        setmetatable(live, _widget_base)
        live.name = name
        live.data = {}

        if overrides then
            for k, v in pairs(overrides) do
                live[k] = v
            end
        end

        if live.init then
            live:init()
        end

        if ambient_pool and ambient_pool ~= "" then
            lstg.SetResourceStatus(ambient_pool)
        end
    end
end

---Creates and registers a new widget instance immediately.
---Use `register_widget` for stage-scoped widgets.
---@param name string Unique name for the widget.
---@param overrides table? Optional fields to override (x, y, rot, scale_h, scale_v, order, visible, active, data, init, frame, render).
---@return core.ui.widget
function M:new_widget(name, overrides)
    assert(type(name) == "string" and name ~= "", "UI Manager: widget name must be a non-empty string.")
    return self:_instantiate_widget(name, overrides)
end

---Removes a widget by name or by reference.
---@param widget core.ui.widget|string
function M:remove(widget)
    local name = type(widget) == "string" and widget or widget.name
    if not self._by_name[name] then return end
    self._by_name[name] = nil
    local list = self._widgets
    for i = 1, #list do
        if list[i].name == name then
            if list[i].del then list[i]:del() end
            table.remove(list, i)
            return
        end
    end
end

---Returns a registered widget by name, or nil if not found.
---@param name string
---@return core.ui.widget?
function M:get(name)
    return self._by_name[name]
end

---Changes the rendering order of a widget and re-sorts the list.
---@param widget core.ui.widget|string
---@param order integer
function M:set_order(widget, order)
    local w = type(widget) == "string" and self._by_name[widget] or widget
    ---@cast w core.ui.widget
    if not w then return end
    local list = self._widgets
    for i = 1, #list do
        if list[i] == w then
            table.remove(list, i)
            break
        end
    end
    w.order = order
    _sortedInsert(list, w)
end

---Removes all registered widgets.
function M:clear()
    local list = self._widgets
    for i = 1, #list do
        if list[i].del then list[i]:del() end
    end
    self._widgets = {}
    self._by_name = {}
end

---Creates all registered widget instances for the current stage.
function M:spawn_registered_widgets()
    for i = 1, #self._def_order do
        local name = self._def_order[i]
        self:_instantiate_widget(name, self._defs[name])
    end
end

---Calls `frame` on every active widget, in render order.
function M:frame()
    local list = self._widgets
    for i = 1, #list do
        local w = list[i]
        if w.active then
            if w.frame then w:frame() end
            w.timer = w.timer + 1
        end
    end
end

---Calls `render` on every visible widget, in render order (lower order drawn first).
function M:render()
    core.view:set("ui")
    local list = self._widgets
    for i = 1, #list do
        local w = list[i]
        if w.visible then
            if w.render then w:render() end
        end
    end
end

core.signals:Register("ui_manager:frame", "Frame", function() M:frame() end, 998)
core.signals:Register("ui_manager:render", "Render", function() M:render() end, 998)
core.signals:Register("ui_manager:stage_start", "stage:start", function()
    M:clear()
    M:spawn_registered_widgets()
end)
core.signals:Register("ui_manager:stage_end", "stage:end", function()
    M:clear()
end)

------------------------------------------------------------
--- Load widgets

local patch = "core.lib.ui.widgets."
require(patch .. "ui_bg")
require(patch .. "score")
require(patch .. "fps")
require(patch .. "diff")