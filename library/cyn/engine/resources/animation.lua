local common = require("cyn.engine.resources.common")
local texture = require("cyn.engine.resources.texture")
local render_target = require("cyn.engine.resources.render_target")
local screen = require("cyn.engine.viewport.screen")

---@class resource.animation : resource_base
local M = {
    name = "",
    type = "ani",
    width = 0,
    height = 0,
    columns = 0,
    rows = 0,
    interval = 0,
    a = 0,
    b = 0,
    rect = false,
    ---@type BlendMode
    blendmode = "",
}

---Loads an animation from a file.
---@param path string path to the image file.
---@param x number x-coordinate of the top-left corner of the first frame in the animation.
---@param y number y-coordinate of the top-left corner of the first frame in the animation.
---@param width number width of each frame in the animation.
---@param height number height of each frame in the animation.
---@param cols number number of columns in the animation sheet.
---@param rows number number of rows in the animation sheet.
---@param interval number time interval between frames.
---@param mipmap boolean? whether to generate mipmaps.
---@param a number? horizontal size of collision
---@param b number? vertical size of collision (same as `a` if nil.)
---@param rect boolean? whether to use rectangular collision instead of circular.
---@return resource.animation Animation
function M.from_file(path, x, y, width, height, cols, rows, interval, mipmap, a, b, rect)
    local name = common.get_typed_name("ani", path)
    local name_tex = common.get_typed_name("tex", path)

    lstg.LoadTexture(name_tex, path, mipmap)
    if common.default_sampler_state then
        lstg.SetTextureSamplerState(name_tex, common.default_sampler_state)
    end
    lstg.LoadAnimation(name, name_tex, x, y, width, height, cols, rows, interval, a or 0, b or a or 0, rect or false)

    local img = MakeInstance(M)
    img.name = name
    img.width = width
    img.height = height
    img.columns = cols
    img.rows = rows
    img.interval = interval
    img.a = a or 0
    img.b = b or a or 0
    img.rect = rect or false
    return img
end

---Loads an image from an existing texture.
---@param tex string|resource.texture|resource.render_target identifier of an existing texture, or texture handler.
---@param x number x-coordinate of the top-left corner of the first frame in the animation.
---@param y number y-coordinate of the top-left corner of the first frame in the animation.
---@param width number width of each frame in the animation.
---@param height number height of each frame in the animation.
---@param cols number number of columns in the animation sheet.
---@param rows number number of rows in the animation sheet.
---@param interval number time interval between frames.
---@param a number? horizontal size of collision
---@param b number? vertical size of collision (same as `a` if nil.)
---@param rect boolean? whether to use rectangular collision instead of circular.
---@return resource.animation Animation
function M.from_texture(tex, x, y, width, height, cols, rows, interval, a, b, rect)
    local img = MakeInstance(M)
    local name

    if type(tex) == "string" then
        local w, h = lstg.GetTextureSize(tex)
        name = common.get_typed_name("ani", tex)
        lstg.LoadAnimation(name, tex, x, y, width, height, cols, rows, interval, a or 0, b or a or 0, rect or false)
        img.width = w
        img.height = h
    elseif type(tex) == "table" and (getmetatable(tex) == texture or getmetatable(tex) == render_target) then
        name = common.get_typed_name("ani", tex.name)
        lstg.LoadAnimation(name, tex.name, x, y, width, height, cols, rows, interval, a or 0, b or a or 0, rect or false)
        img.width = tex.width
        img.height = tex.height
    else
        error("Invalid texture argument for animation creation: must be a texture name or resource.texture or resource.render_target instance.")
    end

    img.name = name
    img.a = a or 0
    img.b = b or a or 0
    img.rect = rect or false
    return img
end

function M:destroy()
    lstg.RemoveResource(self._pool, "ani", self.name)
end

---Gets the size of this image.
---@return number width, number height
function M:get_size()
    return self.width, self.height
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("ani", self.name, true)
    return r == true
end

-------------- State

---@param blendmode BlendMode
function M:set_blendmode(blendmode)
    self.blendmode = blendmode
    lstg.SetAnimationState(self.name, blendmode)
end

---Changes the color of the image.
---@param color1 lstg.Color
---@param color2 lstg.Color?
---@param color3 lstg.Color?
---@param color4 lstg.Color?
function M:set_color(color1, color2, color3, color4)
    lstg.SetAnimationState(self.name, self.blendmode, color1, color2 or color1, color3 or color1, color4 or color1)
end

---Sets the scale of this animation.
---This scale will be applied to all rendering operations WITH hscale and vscale.
---@param scale number
function M:set_scale(scale)
    lstg.SetAnimationScale(self.name, scale)
end
---Returns the scale of this animation.
---@return number
function M:get_scale()
    return lstg.GetAnimationScale(self.name)
end

---Sets the sampler state of this animation.
---@param sampler_state SamplerState
function M:set_sampler_state(sampler_state)
    local name_tex = common.get_typed_name("tex", self.name)
    lstg.SetTextureSamplerState(name_tex, sampler_state)
end

-------------- Rendering

---Renders this animation at the specified coordinates.
---@param timer number
---@param x number
---@param y number
---@param rot number? In degrees
---@param hscale number? Horizontal scale (1.0 by default)
---@param vscale number? If nil, uses the value of `hscale`.
---@param z number? Z index
function M:render(timer, x, y, rot, hscale, vscale, z)
    lstg.RenderAnimation(self.name, timer, x, y, rot or 0, hscale or 1, vscale or hscale or 1, z or 0)
end

return M