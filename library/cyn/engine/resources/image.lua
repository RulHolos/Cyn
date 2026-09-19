local common = require("cyn.engine.resources.common")
local texture = require("cyn.engine.resources.texture")
local render_target = require("cyn.engine.resources.render_target")
local screen = require("cyn.engine.viewport.screen")

---@class resource.image : resource_base
local M = {
    name = "",
    type = "img",
    width = 0,
    height = 0,
    a = 0,
    b = 0,
    rect = false,
    ---@type BlendMode
    blendmode = "",
}

---Loads an image from a file.
---@param path string path to the image file.
---@param mipmap boolean? whether to generate mipmaps.
---@param a number? horizontal size of collision
---@param b number? vertical size of collision (same as `a` if nil.)
---@param rect boolean? whether to use rectangular collision instead of circular.
---@return resource.image Image
function M.from_file(path, mipmap, a, b, rect)
    local name = common.get_typed_name("img", path)
    local name_tex = common.get_typed_name("tex", path)

    lstg.LoadTexture(name_tex, path, mipmap)
    if common.default_sampler_state then
        lstg.SetTextureSamplerState(name_tex, common.default_sampler_state)
    end
    local w, h = lstg.GetTextureSize(name_tex)
    lstg.LoadImage(name, name_tex, 0, 0, w, h, a or 0, b or a or 0, rect or false)

    local img = MakeInstance(M)
    img.name = name
    img.width = w
    img.height = h
    img.a = a or 0
    img.b = b or a or 0
    img.rect = rect or false
    return img
end

---Loads an image from an existing texture.
---@param tex string|resource.texture|resource.render_target identifier of an existing texture, or texture handler.
---@param a number? horizontal size of collision
---@param b number? vertical size of collision (same as `a` if nil.)
---@param rect boolean? whether to use rectangular collision instead of circular.
---@return resource.image Image
function M.from_texture(tex, a, b, rect)
    local img = MakeInstance(M)
    local name

    if type(tex) == "string" then
        local w, h = lstg.GetTextureSize(tex)
        name = common.get_typed_name("img", tex)
        lstg.LoadImage(name, tex, 0, 0, w, h, a or 0, b or a or 0, rect or false)
        img.width = w
        img.height = h
    elseif type(tex) == "table" and (getmetatable(tex) == texture or getmetatable(tex) == render_target) then
        name = common.get_typed_name("img", tex.name)
        lstg.LoadImage(name, tex.name, 0, 0, tex.width, tex.height, a or 0, b or a or 0, rect or false)
        img.width = tex.width
        img.height = tex.height
    else
        error("Invalid texture argument for image creation: must be a texture name or resource.texture or resource.render_target instance.")
    end

    img.name = name
    img.a = a or 0
    img.b = b or a or 0
    img.rect = rect or false
    return img
end

function M:destroy()
    lstg.RemoveResource(self._pool, "img", self.name)
end

---Gets the size of this image.
---@return number width, number height
function M:get_size()
    return self.width, self.height
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("img", self.name, true)
    return r == true
end

-------------- State

---@param blendmode BlendMode
function M:set_blendmode(blendmode)
    self.blendmode = blendmode
    lstg.SetImageState(self.name, blendmode)
end

---Changes the color of the image.
---@param color1 lstg.Color
function M:set_color(color1)
    lstg.SetImageState(self.name, self.blendmode, color1)
end

---Sets the scale of this image.
---This scale will be applied to all rendering operations WITH hscale and vscale.
---@param scale number
function M:set_scale(scale)
    lstg.SetImageScale(self.name, scale)
end
---Returns the scale of this image.
---@return number
function M:get_scale()
    return lstg.GetImageScale(self.name)
end

---Sets the sampler state of this image.
---@param sampler_state SamplerState
function M:set_sampler_state(sampler_state)
    local name_tex = common.get_typed_name("tex", self.name)
    lstg.SetTextureSamplerState(name_tex, sampler_state)
end

-------------- Rendering

---Renders this image at the specified coordinates.
---@param x number
---@param y number
---@param rot number? In degrees
---@param hscale number? Horizontal scale (1.0 by default)
---@param vscale number? If nil, uses the value of `hscale`.
---@param z number? Z index
function M:render(x, y, rot, hscale, vscale, z)
    lstg.Render(self.name, x, y, rot, hscale, vscale, z)
end

---Renders a rectangle filled with this image, within the specified bounds.
---@param left number
---@param right number
---@param bottom number
---@param top number
function M:render_rect(left, right, bottom, top)
    lstg.RenderRect(self.name, left, right, bottom, top)
end

---Renders a image to fill the entire screen. Equivalent to `render_rect(0, screen.LANDSCAPE_W, 0, screen.LANDSCAPE_H)`.
function M:render_screen()
    self:render_rect(0, screen.LANDSCAPE_W, 0, screen.LANDSCAPE_H)
end

---Renders this image in specified vertex position.
---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@param x3 number
---@param y3 number
---@param z3 number
---@param x4 number
---@param y4 number
---@param z4 number
function M:render_4v(x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
    lstg.Render4V(self.name, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
end

---Renders this image in 3d.
---@param x number
---@param y number
---@param z number
---@param rot_x number
---@param rot_y number
---@param rot_z number
---@param scale_x number
---@param scale_y number
function M:render_3d(x, y, z, rot_x, rot_y, rot_z, scale_x, scale_y)
    lstg.Render3D(self.name, x, y, z, rot_x, rot_y, rot_z, scale_x, scale_y)
end

return M