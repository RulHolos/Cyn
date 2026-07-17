---@class core.background : core.object
core.background = core.object.define()
core.background.current = nil

---@param is_sc_bg boolean whether this background is for spell cards
function core.background:init(is_sc_bg)
    self.group = core.object.group.GHOST
    self.bound = false
    if is_sc_bg then
        self.layer = core.object.layer.BACKGROUND
        self.alpha = 0
    else
        self.layer = core.object.layer.BACKGROUND - 0.1
        self.alpha = 1
        if core.background.current and lstg.IsValid(core.background.current) then
            lstg.Del(core.background.current)
        end
        core.background.current = self
    end
end

function core.background:render()
    core.view:set("world")
    core.view:clear(lstg.Color(0))
end

require("core.lib.background.temple.temple")