---@class cyn
local cyn = setmetatable({}, {
    __index = function(_, key)
        error(("Cyn has no sub-module named '%s'."):format(tostring(key)))
    end,
})

---@type cyn
Cyn = cyn

return cyn