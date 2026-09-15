---Context node: I'm fully aware that Flux exposes actual "modern" way of using SOME resources types (textures, images, ...)
---But, for the sake of simplicity and continuity, I chose to stick with the legacy methods.

---@class resources
resources = {}

---@class resource_base
---@field name string Internal name of the resource.
---@field type ResourceTypes
---@field _pool string Resource pool containing this resource.
---@field from_file function Loads the resource from a file. Arguments depend on the resource type.
---@field destroy fun() Cleanup to free the resource from the memory and pool.
---@field is_valid fun() : boolean Checks if the resource is usable.
---@field default_sampler_state SamplerState? Default sampler state to apply to textures/images of this resource type when loaded.

---@generic C
---@param class_type C
---@return C
function makeInstance(class_type)
    class_type.__index = class_type
    local instance = {}
    setmetatable(instance, class_type)
    instance._pool = lstg.GetResourceStatus()
    return instance
end

---Return fully qualified resource name for given type
---@param typename ResourceTypes
---@param file_path string
---@return string
function resources.get_typed_name(typename, file_path)
    local t = ENUM_RES_TYPE[typename]
    assert(t ~= nil, "Invalid resource type: " .. tostring(typename))

    local qualified_name = file_path:match("^.+||(.+)$")
    if qualified_name then
        return typename .. "||" .. qualified_name
    end

    local filename = file_path:match("^.+/(.+)$") or file_path
    filename = filename:match("^(.+)%..+$") or filename
    return typename .. "||" .. filename
end

---Sets the default sampler state for any texture/image loaded after this call. Can be overridden for individual resources with `set_sampler_state`.
---@param state SamplerState
function resources.set_default_sampler_state(state)
    resources.default_sampler_state = state
end

ENUM_RES_TYPE = { tex = 1, img = 2, ani = 3, bgm = 4, snd = 5, psi = 6, fnt = 7, ttf = 8, fx = 9, model = 10, video = 11 }
---@alias ResourceTypes
---| "tex"
---| "img"
---| "ani"
---| "bgm"
---| "snd"
---| "psi"
---| "fnt"
---| "ttf"
---| "fx"
---| "model"
---| "video"

---@alias ResourceTypesClasses
---| resource.texture
---| resource.render_target
---| resource.image
---| resource.music

---Checks if a resource exists by name and type. Disregards pools.
---@param typename ResourceTypes Resource type
---@param resname string Resource name
---@param boolResult boolean? whether to return a boolean instead of the resource name.
---@return boolean|string? Resource name if exists, or true if `boolResult` is true. Otherwise returns nil.
function lstg.CheckNamedRes(typename, resname, boolResult)
    local t = ENUM_RES_TYPE[typename]
    if t == nil then
        error("Invalid resource type: " .. tostring(typename))
    else
        if boolResult then
            return lstg.CheckRes(t, resname) ~= nil
        else
            return lstg.CheckRes(t, resname)
        end
    end
end

local old_remove_res = lstg.RemoveResource

---Removes a resource by name and type from the given pool.
---@param pool string
---@param restype ResourceTypes
---@param resname string
---@diagnostic disable-next-line: duplicate-set-field
function lstg.RemoveResource(pool, restype, resname)
    local t = ENUM_RES_TYPE[restype]
    if t == nil then
        error("Invalid resource type: " .. tostring(restype))
    end

    local actual_pool = lstg.CheckRes(t, resname)
    if actual_pool then
        old_remove_res(actual_pool, t, resname)
    end
end

-------------- Pools

---Sets the active resource pool. Non-existing pools with `pool_name` will be created.
---@param pool_name string
function resources.SetActivePool(pool_name)
    lstg.CreateResourcePool(pool_name) --Skips automatically if it exists
    lstg.SetResourceStatus(pool_name)
end

---Transfers a resource from one pool to another.
---@param from string Source pool name
---@param t ResourceTypes Resource type
---@param name string Resource name
---@param to string Destination pool name
---@overload fun(from:string, resource:ResourceTypesClasses, to:string)
function resources.Transfer(from, t, name, to)
    if not lstg.TransferResource then
        lstg.Log(LOG.INFO, "lstg.TransferResource is not available in your engine version or branch. Make sure you're using LuaSTG-Flux 0.2.4 or higher.")
        return
    end

    if type(t) == "table" then
        local ty = ENUM_RES_TYPE[t.type]
        lstg.TransferResource(from, ty, t.name, name) --Name is `to` in this overload.
    elseif type(t) == "string" then
        local ty = ENUM_RES_TYPE[t]
        if ty == nil then
            error("Invalid resource type: " .. tostring(t))
        else
            lstg.TransferResource(from, name, ty, to)
        end
    end
end

require("resources.image")
require("resources.image_atlas")
require("resources.texture")
require("resources.music")
require("resources.sound")
require("resources.ninepatch")
require("resources.video")
require("resources.ttf")
require("resources.render_target")

require("resources.audio_manager")