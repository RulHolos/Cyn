local object = require("cyn.engine.objects")
local view = require("cyn.engine.viewport.view")
local task = require("cyn.foundation.task")
local tween = require("cyn.foundation.tween")
local menu_node = require("cyn.presentation.menu")
local input = require("cyn.engine.input")

local cfg = require("cyn.presentation.menu.config")

---@class cyn.menu_widget : cyn.menu_node
local widget = object.define(menu_node)

function widget:init(x, y, parent)
    menu_node.init(self, x, y, parent)

    ---Width of the widget. Used for mouse collision.
    self.mouse_bounds_width = 0
    ---Height of the widget. Used for mouse collision.
    self.mouse_bounds_height = 0

    ---If not 0, used as the mouse collision radius, overriding width/height (circle collision only).
    self.mouse_bounds_radius = 0

    self.mouse_x = 0
    self.mouse_y = 0

    self.is_hovering = false
    self.is_selected = false
end

---@return boolean
function widget:is_mouse_hovering()
    if not self.use_mouse then
        return false
    end

    if self.mouse_bounds_radius > 0 then
        return math.is_in_circle(self.mouse_x, self.mouse_y, self.x, self.y, self.mouse_bounds_radius)
    end

    return math.is_in_rect(self.mouse_x, self.mouse_y, self.x, self.y, self.mouse_bounds_width, self.mouse_bounds_height)
end

function widget:frame()
    menu_node.frame(self)

    if self.lock then
        return
    end

    if self.use_mouse then
        self.mouse_x, self.mouse_y, _, _ = input:get_normalized_mouse_position()

        if self:is_mouse_hovering() then
            if not self.is_hovering then
                self:hover()
            end
        elseif self.is_hovering then
            self:un_hover()
        end

        if input:mouse_is_pressed(cfg.click_mouse_button) and self.is_hovering then
            self:click()
        end
    end

    if input:is_pressed(cfg.confirm_key) and self.is_selected then
        self:activate()
    end
end

---The widget was clicked with a mouse.
function widget:click()
end

---The user pressed the confirm key while this widget was selected.
function widget:activate()
end

---The cursor moved to this widget (keyboard). Hovering also selects (not the other way around).
---
---Called once when the widget is selected.
function widget:select()
    self.is_selected = true
end

---The cursor moved away from this widget (keyboard).
---
---Called once when the widget is unselected.
function widget:unselect()
    self.is_selected = false
end

---The mouse entered this widget's bounds.
---
---Called once per hover start.
function widget:hover()
    self.is_hovering = true
    self:select()
end

---The mouse left this widget's bounds. Doesn't call :unselect().
---
---Called once per hover end.
function widget:un_hover()
    self.is_hovering = false
end

---Does nothing on its own. Override to react to external state changes.
---
---(Example: refresh language display)
function widget:refresh()
end

return widget
