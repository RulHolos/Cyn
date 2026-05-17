---@class resource.image_atlas : resource_base
local M = {
    name = "",
    type = "atlas",
}
resources.image_atlas = M

---Creates a basic empty atlas from a texture.
---@param path string path to the texture file.
---@param mipmap boolean? whether to generate mipmaps.
---@return resource.image_atlas
function M.from_file(path, mipmap)
    local name_tex = resources.get_typed_name("tex", path)

    lstg.LoadTexture(name_tex, path, mipmap or false)
    if resources.default_sampler_state then
        lstg.SetTextureSamplerState(name_tex, resources.default_sampler_state)
    end

    local atlas = makeInstance(M)
    atlas.name = name_tex
    return atlas
end

function M.from_texture(tex)
    local atlas = makeInstance(M)
    local name

    if type(tex) == "string" then
        name = tex
    elseif type(tex) == "table" and getmetatable(tex) == resources.texture then
        name = tex.name
    else
        error("Invalid texture argument for atlas creation: must be a texture name or resource.texture instance.")
    end

    atlas.name = name
    return atlas
end

function M:destroy()
    lstg.RemoveResource(lstg.GetResourceStatus(), "tex", self.name)
    --TODO: Also clear any other resources created by this atlas
end

function M:get_parts_count()
    --TODO: Return the number of resources of this atlas
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("tex", self.name, true)
    return r == true
end

-------------- State

---Sets the sampler state of this atlas.
---@param sampler_state SamplerState
function M:set_sampler_state(sampler_state)
    lstg.SetTextureSamplerState(self.name, sampler_state)
end

-------------- Methods