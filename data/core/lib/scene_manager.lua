-- ============= --
-- Scene Manager --
-- ============= --

---@alias StageType "stage"|"group"

------------------------------------------------------------
--- Stage

---@class core.stage
---@field type StageType
---@field name string
---@field is_menu boolean
---@field is_entry boolean
---@field timer integer
---@field init fun(self:core.stage)
---@field frame fun(self:core.stage)
---@field render fun(self:core.stage)
---@field del fun(self:core.stage)
local _s = {
    type = "stage",
    name = "",
    is_menu = false,
    is_entry = false,
    timer = 0,
    init = function(self) end,
    frame = function(self) end,
    render = function(self) end,
    del = function(self) end,
}

---@param name string
---@param overrides table?
---@return core.stage
local function new_stage_object(name, overrides)
    local s = {}
    for k, v in pairs(_s) do
        s[k] = v
    end
    s.name = name
    if overrides then
        for k, v in pairs(overrides) do
            s[k] = v
        end
    end
    return s
end

------------------------------------------------------------
--- Stage Group

---@class core.stage_group
---@field type StageType
---@field name string
---@field stages string[] Ordered list of fully-qualified stage names.
---@field current_index integer
---@field after string|nil Name of stage/group to load when group ends.
local stage_group = {
    type = "group",
    name = "",
    stages = {},
    current_index = 1,
    after = nil,
}

---Registers a stage inside this group.
---Stage name qualified as 'name@group_name'.
---@param stage core.stage
---@return core.stage @self
---@private
function stage_group:register_stage(stage)
    stage.name = ("%s@%s"):format(stage.name, self.name)
    table.insert(self.stages, stage.name)
    return stage
end

function stage_group:new_stage(name)
    local qualified_name = ("%s@%s"):format(name, self.name)
    local stage = core.stage_manager.stages[qualified_name]
    if stage then
        for k in pairs(stage) do stage[k] = nil end
        for k, v in pairs(_s) do stage[k] = v end
        stage.name = qualified_name
    else
        stage = new_stage_object(name)
        self:register_stage(stage)
        core.stage_manager.stages[stage.name] = stage
    end
    table.insert(self.stages, stage.name)
    return stage
end

---Resets the group to 1, so it can be played again. Should be called when the group ends.
function stage_group:reset()
    self.current_index = 1
end

---Returns the name of the next stage to load. nil if none.
---@return string?
function stage_group:advance()
    local name = self.stages[self.current_index]
    if name then
        self.current_index = self.current_index + 1
    end
    return name
end

---@class core.stage_manager
---@field stages table<string, core.stage>
---@field groups table<string, core.stage_group>
---@field current_stage core.stage?
---@field current_group core.stage_group?
---@field next core.stage|core.stage_group|nil
---@field menu_name core.stage?
---@field entry_name core.stage?
local M = {
    stages = {},
    groups = {},
    current_stage = nil,
    current_group = nil,
    next = nil,
    menu_name = nil,
    entry_name = nil,
}
core.stage_manager = M

---Creates and registers a new orphan stage (menu or entry point).
---
---```lua
---local splash = stage_manager:new_stage("splash", { entry_point = true })
---function splash:init() end
---
---local menu = stage_manager:new_stage("menu", { menu = true })
---```
function M:new_stage(name, opts)
    opts = opts or {}
    assert(type(name) == "string" and name ~= "", "Stage name must be a non-empty string.")

    local stage = self.stages[name]
    if stage then
        for k in pairs(stage) do
            stage[k] = nil
        end
        for k, v in pairs(_s) do
            stage[k] = v
        end
        stage.name = name
    else
        stage = new_stage_object(name)
        self.stages[name] = stage
    end

    stage.is_menu = opts.menu or false
    stage.is_entry = opts.entry_point or false

    if stage.is_entry and self.entry_name ~= name then
        if self.entry_name then
            error(("StageManager: entry point already set to '%s'."):format(self.entry_name))
        end
        self.entry_name = name
        self.next = stage -- queued automatically.
    end

    if stage.is_menu and self.menu_name ~= name then
        if self.menu_name then
            error(("StageManager: menu already set to '%s'."):format(self.menu_name))
        end
        self.menu_name = name
    end

    return stage
end

---Creates and registers a new stage group.
---
---```lua
---local easy = stage_manager:new_group("easy")
---local s1 = easy:new_stage("1")
---function s1:init() end
---```
---@param name string
---@param opts {after: string?}? `after`: name of the stage/group to go when this group ends.
---@return core.stage_group
function M:new_group(name, opts)
    opts = opts or {}
    assert(type(name) == "string" and name ~= "", "Stage group name must be a non-empty string.")

    if self.groups[name] then
        error(("StageManager: a stage group named '%s' already exists."):format(name))
    end

    local group = {}
    for k, v in pairs(stage_group) do
        group[k] = v
    end
    group.name = name
    group.stages = {}
    group.after = opts.after or nil

    self.groups[name] = group
    return group
end

---Queues the next stage without changing the current stage.
---
---Useful for deciding the next stage dynamically.
---Can even be a group if you want to. (idk why you would tho)
---@param name string Name of an existing stage or group.
function M:set_next(name)
    local target = self.stages[name] or self.groups[name]
    if not target then
        error(("StageManager: no stage or group named '%s' found."):format(name))
    end
    self.next = target
end

---Jump to another stage or stage group.
---@param name string Name of an existing stage or group.
function M:goto(name)
    self:set_next(name)
    self:switch()
end

---Advances to the next stage or group of stage.
---
---- **Group context**: loads the next stage in the active group.
---  When the group is emmpty, if exists to `group.after` or menu stage.
---  No need to call `set_next` in this context.
---
---- **Orphan context**: you must have queued a destination first
---  with `set_next` or `goto`.
function M:switch()
    self:stop_current()

    -- Group
    if self.current_group then
        local next_name = self.current_group:advance()
        if next_name then
            self:load_stage(self.stages[next_name])
            return
        end

        local exit_name = self.current_group.after or self.menu_name
        self.current_group:reset()
        self.current_group = nil

        if not exit_name then
            error(("StageManager: no menu stage to return to after finishing group '%s'."):format(self.current_group.name))
        end

        local exit_target = self.groups[exit_name] or self.stages[exit_name]
        if not exit_target then
            error(("StageManager: no stage or group named '%s' found."):format(exit_name))
        end

        self:load_target(exit_target)
        return
    end

    -- Orphan stage
    if not self.next then
        error("StageManager: no stage queued to switch to.")
    end

    local target = self.next
    self.next = nil
    self:load_target(target)
end

---@param target core.stage|core.stage_group|nil
---@private
function M:load_target(target)
    assert(target ~= nil, "StageManager: target cannot be nil.")

    if target.type == "stage" then
        self.current_group = nil
        ---@cast target core.stage
        self:load_stage(target)
    elseif target.type == "group" then
        ---@cast target core.stage_group
        self.current_group = target
        local first_name = target:advance()
        if not first_name then
            error(("StageManager: stage group '%s' is empty."):format(target.name))
        end
        local first_stage = self.stages[first_name]
        if not first_stage then
            error(("StageManager: no stage named '%s' found."):format(first_name))
        end
        self:load_stage(first_stage)
    else
        error("StageManager: invalid target type.")
    end
end

---@private
function M:stop_current()
    if not self.current_stage then
        return
    end

    self.current_stage:del()
    lstg.ResetPool()
    lstg.RemoveResource("stage")
    core.signals:Emit("stage:end", self.current_stage)

    self.current_stage = nil
end

---@param stage core.stage
---@private
function M:load_stage(stage)
    assert(stage ~= nil, "StageManager: stage cannot be nil.")

    lstg.SetResourceStatus("stage")

    self.current_stage = stage
    self.current_stage.timer = 0
    self.current_stage:init()
    core.signals:Get("ui_manager:render", "Render"):SetEnabled(not self.current_stage.is_menu) --Only allow if the current stage is a game stage.

    core.signals:Emit("stage:start", self.current_stage)
end

---@private
function M:_frame()
    if not self.current_stage then
        return
    end
    core.task.Do(self.current_stage)
    self.current_stage:frame()
    self.current_stage.timer = self.current_stage.timer + 1
end

---@private
function M:_render()
    if not self.current_stage then
        return
    end
    self.current_stage:render()
end

core.signals:Register("stage_manager:init", "Init", function()
    if not M.entry_name and not M.next then
        error("StageManager: no entry point defined. Please create a stage with the 'entry_point' flag or queue a stage/group with set_next.")
    end
    M:switch()
end)

core.signals:Register("stage_manager:frame", "Frame", function() M:_frame() end, 999)
core.signals:Register("stage_manager:render", "Render", function() M:_render() end, 999)

return M