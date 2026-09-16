---@class core.class
local M = {}

local function classCreate(instance, class, ...)
    local ctor = rawget(class, "init")
    if ctor then
        ctor(instance, ...)
    else
        local super = rawget(class, "super")
        if super then
            classCreate(instance, super, ...)
        end
    end
end

local function new(class, ...)
    local instance = {}
    setmetatable(instance, { __index = class })
    classCreate(instance, class, ...)
    return instance
end

local function indexer(class, key)
    local cache = rawget(class, "_indexer")
    local member = cache[key]
    if member == nil then
        local base = rawget(class, "super")
        if base then
            member = base[key]
            if member ~= nil then
                cache[key] = member
            end
        end
    end
    return member
end

---Creates a new class, optionally inheriting from a base class.
---@generic T
---@param base T?
---@return T
function M.class(base)
    assert(base == nil or type(base) == "table", "class base must be a table or nil")

    local class = { super = base, _indexer = {} }

    setmetatable(class, {
        __call = new,
        __index = indexer,
    })

    return class
end

return M