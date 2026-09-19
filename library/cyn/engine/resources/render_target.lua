local common = require("cyn.engine.resources.common")

---@class resource.render_target : resource_base
---@field width number
---@field height number
local M = {
    name = "",
    type = "tex",
    width = 0,
    height = 0,
}

---Creates a render target texture.
---@param name string Internal resource name.
---@param width number
---@param height number
---@return resource.render_target
function M.from_size(name, width, height)
    assert(type(name) == "string" and name ~= "", "Render target name must be a non-empty string.")
    assert(width > 0 and height > 0, "Render target dimensions must be positive.")

    lstg.CreateRenderTarget(name, width, height)
    if common.default_sampler_state then
        lstg.SetTextureSamplerState(name, common.default_sampler_state)
    end

    local target = MakeInstance(M)
    target.name = name
    target.width = width
    target.height = height
    return target
end

function M.new(name)
    assert(type(name) == "string" and name ~= "", "Render target name must be a non-empty string.")

    lstg.CreateRenderTarget(name)
    if common.default_sampler_state then
        lstg.SetTextureSamplerState(name, common.default_sampler_state)
    end

    ---TODO: Return correct width and height
    local target = MakeInstance(M)
    target.name = name
    target.width = 0
    target.height = 0
    return target
end

function M:destroy()
    lstg.RemoveResource(self._pool, "tex", self.name)
end

---@return boolean
function M:is_valid()
    return lstg.CheckNamedRes("tex", self.name) ~= nil and lstg.IsRenderTarget(self.name)
end

---Gets the size of this render target.
---@return number width, number height
function M:get_size()
    return self.width, self.height
end

---Sets the sampler state of this render target texture.
---@param sampler_state SamplerState
function M:set_sampler_state(sampler_state)
    lstg.SetTextureSamplerState(self.name, sampler_state)
end

function M:save_to_file(path)
    lstg.SaveTexture(self.name, path)
end

---Pushes this target as the current render destination.
---@param clear boolean? Whether to render clear right after pushing. Defaults to false
function M:push(clear)
    lstg.PushRenderTarget(self.name)
    if clear then
        lstg.RenderClear(0)
    end
end

---Pops the current render destination.
function M:pop()
    lstg.PopRenderTarget()
end

return M