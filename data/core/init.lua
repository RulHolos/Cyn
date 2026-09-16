---@class core
local core = setmetatable({}, {
    __index = function(_, key)
        error(("core has no sub-module named '%s'."):format(tostring(key)))
    end,
})

_G.core = core

return core