---@class Cyn
local cyn = setmetatable({}, {
    __index = function(_, key)
        error(("Cyn has no sub-module named '%s'."):format(tostring(key)))
    end,
})

---@type Cyn
Cyn = cyn

return cyn