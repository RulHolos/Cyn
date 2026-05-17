---@class menu_manager
local menu = {
    timer = 0,
    active_menu = nil,
    menu_stack = {} -- Stack to keep track of the last selected menus. Can be accessed to go back to the last selected menu.
}
menu.__index = menu

---Creates a new menu manager.
---@return menu_manager
function menu.create()
    local self = makeInstance(menu)
    return self
end

function menu:frame()
    self.timer = self.timer + 1
    core.tween.Do(self)
end

function menu:render()
end

function menu:go_back()
end