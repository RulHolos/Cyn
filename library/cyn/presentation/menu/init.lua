local object = require("cyn.engine.objects")
local view = require("cyn.engine.viewport.view")
local task = require("cyn.foundation.task")
local tween = require("cyn.foundation.tween")

local cfg = require("cyn.presentation.menu.config")

---@class cyn.menu_node : cyn.object
local menu_node = object.define()

---@param parent cyn.menu_node? If given, this node will be placed one layer above the parent and registered as its child.
---@param x number
---@param y number
function menu_node:init(x, y, parent)
    self.x, self.y = x, y
    self.parent = parent
    self.layer = parent and (parent.layer + cfg.layer_step) or (object.layer.TOP + cfg.base_layer_offset)
    self.group = object.group.GHOST
    self.alpha = 0
    self.bound = false
    self.use_mouse = cfg.use_mouse

    self.lock = true
    self.hide = true
    self.entering = false
    self.exiting = false

    ---@type cyn.menu_node[]
    self.children = {}

    if parent then
        parent:add_child(self)
    end
end

---Registers child under this node and positions it one layer above.
---@param child cyn.menu_node
---@return cyn.menu_node child
function menu_node:add_child(child)
    child.parent = self
    child.layer = self.layer + cfg.layer_step
    self.children[#self.children + 1] = child

    return child
end

---@param child cyn.menu_node
function menu_node:remove_child(child)
    for i = 1, #self.children do
        if self.children[i] == child then
            table.remove(self.children, i)
            break
        end
    end
end

function menu_node:frame()
    tween.Do(self)
    task.exec(self)

    if self.entering and self.alpha >= 255 then
        self.entering = false
        self.lock = false
        self:on_enter_complete()
    end

    if self.exiting and self.alpha <= 0 then
        self.exiting = false
        self.hide = true
        self:on_exit_complete()
    end
end

function menu_node:render()
    view:set("ui")
end

---Called once when the node appears. Cascades to every child.
function menu_node:enter()
    self.hide = false
    self.entering = true
    tween.New(self, { alpha = 255 }, cfg.fade_time):ease(cfg.fade_ease)

    for i = 1, #self.children do
        self.children[i]:enter()
    end
end

---Called once when the node disappears. Cascades to every child.
---@param reason string? Why the node is exiting (e.g. "back", "next"). Stored on self for subclasses to inspect.
---@param time integer? Frames the fade-out takes. Defaults to cfg.fade_time.
function menu_node:exit(reason, time)
    self.lock = true
    self.exiting = true
    self.exit_reason = reason
    tween.New(self, { alpha = 0 }, time or cfg.fade_time):ease(cfg.fade_ease)

    for i = 1, #self.children do
        self.children[i]:exit(reason, time)
    end
end

---Called once when the enter fade finishes.
---
---Override to react (default: unlocks input).
function menu_node:on_enter_complete()
end

---Called once when the exit fade finishes.
---
---Override to react (default: hides the node).
function menu_node:on_exit_complete()
end

---Releases node-owned resources and cascades to children.
---
---Override to free extra resources, calling menu_node.del(self) to keep cascading.
function menu_node:del()
    for i = 1, #self.children do
        self.children[i]:del()
    end
end

return menu_node