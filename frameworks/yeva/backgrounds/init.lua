local object = require("cyn.engine.objects")
local view = require("cyn.engine.viewport.view")

---@class yeva.background : cyn.object
local M = object.define()
M.current = nil

---@param is_sc_bg boolean whether this background is for spell cards
function M:init(is_sc_bg)
    self.group = object.group.GHOST
    self.bound = false
    if is_sc_bg then
        self.layer = object.layer.BACKGROUND
        self.alpha = 0
    else
        self.layer = object.layer.BACKGROUND - 0.1
        self.alpha = 1
        if M.current and lstg.IsValid(M.current) then
            lstg.Del(M.current)
        end
        M.current = self
    end
end

function M:render()
    view:set("world")
    view:clear(lstg.Color(0))
end

function M:load_all()
    require("yeva.backgrounds.temple")
end

return M