---@class core
---@field userdata core.userdata
---@field signals core.signals
---@field screen core.screen
---@field world core.world
---@field world_camera core.world_camera
---@field camera3d core.camera3d
---@field view core.view
---@field coords core.coords
---@field input core.input
---@field object core.object
---@field tween core.tween
---@field player core.player
---@field background core.background
---@field stage_manager core.stage_manager
local M = {}
core = M
core.__index = M
core.quit_flag = false

---@generic T
---@param base T?
---@return T
function M.class(base)
    local class = { super = base, _indexer = {} }

    local function classCreate(instance, _class, ...)
        local ctor = rawget(_class, "init")
        if ctor then
            ctor(instance, ...)
        else
            local super = rawget(_class, "super")
            if super then
                classCreate(instance, super, ...)
            end
        end
    end

    local function new(t, ...)
        local instance = {}
        setmetatable(instance, { __index = t })
        classCreate(instance, t, ...)
        return instance
    end

    local function indexer(t, k)
        local member = t._indexer[k]
        if member == nil then
            if base then
                member = base[k]
                t._indexer[k] = member
            end
        end
        return member
    end

    setmetatable(class, {
        __call = new,
        __index = indexer,
    })

    return class
end

require("core.lib.cdf")
require("i18n") --Don't ask why it's there. It just is...

require("core.lib.task")
require("core.lib.signals")
require("core.lib.userdata")
require("core.lib.settings")
require("core.lib.objects")
require("core.lib.task")
require("core.lib.tween")
require("core.lib.debug")
require("core.lib.screen")
require("core.lib.scene_manager")
require("core.lib.random")
require("core.lib.ui")
require("core.lib.input")

require("core.lib.misc")
require("core.lib.item")
require("core.lib.player")
require("core.lib.background")

require("core.lib.mainloop")