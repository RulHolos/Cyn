local common = require("core.engine.resources.common")

---@class resource.texture
---@field name string Internal name of the texture. Can be used to reference this texture in other resources.
---@field _pool string Resource pool containing this texture.
local M = {
    name = "",
    type = "tex",
    width = 0,
    height = 0,
    ---@type BlendMode
    blendmode = "",
}

function M.from_file(path, mipmap)
    local name = common.get_typed_name("tex", path)

    lstg.LoadTexture(name, path, mipmap)
    if common.default_sampler_state then
        lstg.SetTextureSamplerState(name, common.default_sampler_state)
    end
    local w, h = lstg.GetTextureSize(name)

    local tex = makeInstance(M)
    tex.name = name
    tex.width = w
    tex.height = h
    return tex
end

function M:save_to_file(path)
    lstg.SaveTexture(self.name, path)
end

function M:destroy()
    lstg.RemoveResource(self._pool, "tex", self.name)
end

---Gets the size of this texture.
---@return number width, number height
function M:get_size()
    return self.width, self.height
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("tex", self.name, true)
    return r == true
end

-------------- State

---Sets the sampler state of this texture.
---@param sampler_state SamplerState
function M:set_sampler_state(sampler_state)
    lstg.SetTextureSamplerState(self.name, sampler_state)
end

function M:render()
    --lstg.RenderTexture(self.name, self.blendmode) -- TODO
end

return M