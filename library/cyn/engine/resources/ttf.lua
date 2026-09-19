local common = require("cyn.engine.resources.common")

---@class resource.ttf : resource_base
local M = {
    name = "",
    type = "ttf",
    size = 0,
    ---@type BlendMode
    blendmode = "",
}

function M.from_file(path, size)
    local name = common.get_typed_name("ttf", path)

    lstg.LoadTTF(name, path, size, size)

    local ttf = MakeInstance(M)
    ttf.name = name
    ttf.size = size
    return ttf
end

function M:destroy()
    lstg.RemoveResource(self._pool, "ttf", self.name)
end

---@return boolean Validity
function M:is_valid()
    local r = lstg.CheckNamedRes("ttf", self.name, true)
    return r == true
end

---Creates a RichText object from this font (with same size).
---@return lstg.RichText
function M:rich_text()
    return lstg.RichText.createFromPool(self.name, self.size)
end

-------------- State

---Changes the color and blendmode of the image.
---@param blendmode BlendMode
---@param color lstg.Color
function M:set_state(blendmode, color)
    lstg.RichText:setState(blendmode, color)
    self.blendmode = blendmode
end

return M