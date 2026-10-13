local player = require("yeva.player")
local cls = require("cyn.engine.class")
local signals = require("cyn.foundation.signals")
local view = require("cyn.engine.viewport.view")
local tween = require("cyn.foundation.tween")
local easing = require("cyn.global_scripts.easing")
local ImGui = require("imgui").ImGui

--#region Support

---@class yeva.player.behavior.supports.support
---@field parent yeva.player.behavior.supports
local support = {}

---Call this to initialize base data, you can then set individual values.
---@param unfocused_offset { x: number, y: number }?
---@param focused_offset { x: number, y: number }?
---@param tween_duration integer? Frames for the offset transition. Defaults to 0.15.
---@param tween_ease EasingType? Defaults to "linear"
function support:init(unfocused_offset, focused_offset, tween_duration, tween_ease)
    ---@type { x: number, y: number } Unfocused offset to the player's position
    self.unfocused_offset = unfocused_offset or { x = 0, y = 0 }
    ---@type { x: number, y: number } Focused offset to the player's position
    self.focused_offset = focused_offset or { x = 0, y = 0 }

    ---@type { x: number, y: number } Current interpolated offset, tweened between the two above
    self.offset = { x = self.unfocused_offset.x, y = self.unfocused_offset.y }

    self.tween_duration = tween_duration or (1 / 0.15)
    self.tween_ease = tween_ease or "linear"

    ---@type boolean Cached focus state, used to detect changes
    self.focusing = false

    ---@type boolean Whether this support is currently part of the active formation and should render. Always true for manual supports.
    self.active = true

    ---@type resource.image?
    self.img = nil

    self.rot = 0
    self.hscale = 1
    self.vscale = self.hscale
end

---Override this to give specific behavior for your support object.
function support:frame()
end

---Do not override this unless you know what you're doing.
---
---This function is responsible for handling movement and updating the support's position relative to the player.
function support:frame_movement()
    local move = self.parent.move
    if move then
       local focusing = move.is_focus

        if focusing ~= self.focusing then
            self.focusing = focusing

            local target = focusing and self.focused_offset or self.unfocused_offset

            tween.Stop(self.offset)
            tween.New(self.offset, { x = target.x, y = target.y }, self.tween_duration):ease(self.tween_ease)
        end

        tween.Do(self.offset)

        local owner = self.parent.player

        self.x = owner.x + self.offset.x
        self.y = owner.y + self.offset.y
    end
end

function support:render()
    if not self.active then return end

    view:set("world")

    if self.img then
        self.img:render(self.x, self.y, self.rot, self.hscale, self.vscale)
    end
end

--#endregion

---@class yeva.player.behavior.supports : yeva.player.behavior
local M = player.behavior.define("supports")

---@param unfocused_offset { x: number, y: number }?
---@param focused_offset { x: number, y: number }?
---@param tween_duration integer?
---@param tween_ease EasingType?
---@return yeva.player.behavior.supports.support
function M:make_support(unfocused_offset, focused_offset, tween_duration, tween_ease)
    local inst = MakeInstance(support)
    inst.parent = self

    inst:init(unfocused_offset, focused_offset, tween_duration, tween_ease)

    table.insert(self.supports, inst)
    return inst
end

--#region Formation

---@class yeva.player.behavior.supports.formation_level
---@field power number Power level from which `count` applies, until the next level's power is reached.
---@field count integer Number of active supports while this level applies.

---@alias yeva.player.behavior.supports.position_fn fun(index: integer, count: integer, focused: boolean): { x: number, y: number }

---@class yeva.player.behavior.supports.formation
---@field levels yeva.player.behavior.supports.formation_level[]
---@field position_fn yeva.player.behavior.supports.position_fn
---@field supports yeva.player.behavior.supports.support[] Pool sized to the highest `count` across all levels.
---@field active_count integer
local formation_mt = {}

---Computes the number of active supports for the given power, based on this formation's levels.
---@param power number
---@return integer
function formation_mt:count_for_power(power)
    local count = 0
    for _, level in ipairs(self.levels) do
        if power >= level.power then
            count = level.count
        end
    end
    return count
end

---Recalculates active supports and tweens them into existence.
function formation_mt:refresh(power)
    local count = self:count_for_power(power)
    if count == self.active_count then return end
    self.active_count = count

    for i, inst in ipairs(self.supports) do
        inst.active = i <= count

        if inst.active then
            inst.unfocused_offset = self.position_fn(i, count, false)
            inst.focused_offset = self.position_fn(i, count, true)

            local target = inst.focusing and inst.focused_offset or inst.unfocused_offset
            tween.Stop(inst.offset)
            tween.New(inst.offset, { x = target.x, y = target.y }, inst.tween_duration):ease(inst.tween_ease)
        end
    end
end

---Sets up a pool of supports with count and positions depending on the player's current power.
---@param levels yeva.player.behavior.supports.formation_level[]
---@param position_fn yeva.player.behavior.supports.position_fn
---@param make_fn fun(inst: yeva.player.behavior.supports.support, index: integer)? Called once per pooled support.
---@param tween_duration integer?
---@param tween_ease EasingType?
---@return yeva.player.behavior.supports.support[] The full pool of supports (including currently inactives).
function M:make_formation(levels, position_fn, make_fn, tween_duration, tween_ease)
    table.sort(levels, function(a, b) return a.power < b.power end)

    local max_count = 0
    for _, level in ipairs(levels) do
        max_count = math.max(max_count, level.count)
    end

    local formation = setmetatable({
        levels = levels,
        position_fn = position_fn,
        supports = {},
        active_count = -1, --Force refresh on first call
    }, { __index = formation_mt })

    for i = 1, max_count do
        local inst = MakeInstance(support)
        inst.parent = self
        inst:init(nil, nil, tween_duration, tween_ease)
        inst.active = false

        if make_fn then
            make_fn(inst, i)
        end

        table.insert(self.supports, inst)
        table.insert(formation.supports, inst)
    end

    table.insert(self.formations, formation)
    return formation.supports
end

--#endregion

function M:init()
    ---@type yeva.player.behavior.supports.support[]
    self.supports = {}

    ---@type yeva.player.behavior.supports.formation[]
    self.formations = {}
end

function M:get_deps()
    ---@type yeva.player.behavior.move?
    self.move = self.player:get_behavior("move")
    assert(self.move ~= nil, "A move behavior must be attached for this stock behavior to work.")

    ---@type yeva.player.behavior.power?
    self.power = self.player:get_behavior("power")
    assert(self.power ~= nil, "A power behavior must be attached for this stock behavior to work.")
end

function M:frame()
    for _, formation in ipairs(self.formations) do
        formation:refresh(self.power.current_power)
    end

    for _, support in ipairs(self.supports) do
        support:frame()
        support:frame_movement()
    end
end

function M:render()
    for _, support in ipairs(self.supports) do
        support:render()
    end
end

function M:debug()
    --TODO: Allow modifying supports formations.
end

return M
