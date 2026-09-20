local common = require("cyn.engine.resources.common")
local image = require("cyn.engine.resources.image")
local texture = require("cyn.engine.resources.texture")
local render_target = require("cyn.engine.resources.render_target")

---@class resource.image_atlas : resource_base
local M = {
    name = "",
    type = "atlas",
    ---@type table<string, resource.image> Sub-images loaded from this atlas, keyed by name suffix.
    parts = {},
}

---Creates a basic empty atlas from a texture.
---@param path string path to the texture file.
---@param mipmap boolean? whether to generate mipmaps.
---@return resource.image_atlas
function M.from_file(path, mipmap)
    local name_tex = common.get_typed_name("tex", path)

    lstg.LoadTexture(name_tex, path, mipmap or false)
    if common.default_sampler_state then
        lstg.SetTextureSamplerState(name_tex, common.default_sampler_state)
    end

    local atlas = MakeInstance(M)
    atlas.name = name_tex
    return atlas
end

function M.from_texture(tex)
    local atlas = MakeInstance(M)
    local name

    if type(tex) == "string" then
        name = tex
    elseif type(tex) == "table" and (getmetatable(tex) == texture or getmetatable(tex) == render_target) then
        name = tex.name
    else
        error("Invalid texture argument for atlas creation: must be a texture name or resource.texture or resource.render_target instance.")
    end

    atlas.name = name
    return atlas
end

function M:destroy()
    for _, img in pairs(self.parts) do
        lstg.RemoveResource(img._pool, "img", img.name)
    end
    self.parts = {}
    lstg.RemoveResource(self._pool, "tex", self.name)
end

function M:get_parts_count()
    local count = 0
    for _ in pairs(self.parts) do count = count + 1 end
    return count
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

---Returns a sub-image previously loaded from this atlas, or nil if not found.
---@param name_suffix string
---@return resource.image?
function M:get_image(name_suffix)
    return self.parts[name_suffix]
end

---Defines a sub-image from this atlas.
---@param name_suffix string Unique name for the sub-image.
---@param x number X offset in the texture (pixels).
---@param y number Y offset in the texture (pixels).
---@param w number Width of the sub-image (pixels).
---@param h number Height of the sub-image (pixels).
---@param a number? Collision width.
---@param b number? Collision height (defaults to `a`).
---@param rect boolean? Use rectangular collision.
---@return resource.image
function M:add_image(name_suffix, x, y, w, h, a, b, rect)
    local name = self.name .. "/" .. name_suffix
    lstg.LoadImage(name, self.name, x, y, w, h, a or 0, b or a or 0, rect or false)
    local img = MakeInstance(image)
    img.name = name
    img.width = w
    img.height = h
    img.a = a or 0
    img.b = b or a or 0
    self.parts[name_suffix] = img
    return img
end

---Defines a horizontal strip of animation frames from this atlas.
---@param name_prefix string Prefix for each frame name (frame index is appended).
---@param x number X offset of the first frame (pixels).
---@param y number Y offset of the strip (pixels).
---@param w number Width of each frame (pixels).
---@param h number Height of each frame (pixels).
---@param count integer Number of frames.
---@param a number? Collision width.
---@param b number? Collision height (defaults to `a`).
---@param rect boolean? Use rectangular collision.
---@return resource.image[]
function M:add_animation_strip(name_prefix, x, y, w, h, count, a, b, rect)
    local frames = {}
    for i = 1, count do
        local name = self.name .. "/" .. name_prefix .. i
        lstg.LoadImage(name, self.name, x + (i - 1) * w, y, w, h, a or 0, b or a or 0, rect or false)
        local img = MakeInstance(image)
        img.name = name
        img.width = w
        img.height = h
        img.a = a or 0
        img.b = b or a or 0
        img.rect = rect or false
        frames[i] = img
        self.parts[name_prefix .. i] = img
    end
    return frames
end

---Defines a grid of sub-images from this atlas, to left-to-right and top-to-bottom.
---@param name_prefix string Prefix for each image name (1-based index is appended).
---@param x number X offset of the top-left cell (pixels).
---@param y number Y offset of the top-left cell (pixels).
---@param w number Width of each cell (pixels).
---@param h number Height of each cell (pixels).
---@param cols integer Number of columns.
---@param rows integer Number of rows.
---@param a number? Collision width.
---@param b number? Collision height (defaults to `a`).
---@param rect boolean? Use rectangular collision.
---@return resource.image[]
function M:add_image_group(name_prefix, x, y, w, h, cols, rows, a, b, rect)
    local images = {}
    for i = 0, cols * rows - 1 do
        local suffix = name_prefix .. (i + 1)
        local name = self.name .. "/" .. suffix
        lstg.LoadImage(name, self.name, x + w * (i % cols), y + h * math.floor(i / cols), w, h, a or 0, b or a or 0, rect or false)
        local img = MakeInstance(image)
        img.name = name
        img.width = w
        img.height = h
        img.a = a or 0
        img.b = b or a or 0
        img.rect = rect or false
        images[i + 1] = img
        self.parts[suffix] = img
    end
    return images
end

function M:render_ring(suffix, x, y, r1, r2, rot, n, nimg)
    local da = 360 / n
    local a = rot
    for i = 1, n do
        a = rot - da * i
        lstg.Render4V(self:get_image(suffix .. ((i - 1) % nimg + 1)).name,
            r1 * cos(a + da) + x, r1 * sin(a + da) + y, 0.5,
            r2 * cos(a + da) + x, r2 * sin(a + da) + y, 0.5,
            r2 * cos(a) + x, r2 * sin(a) + y, 0.5,
            r1 * cos(a) + x, r1 * sin(a) + y, 0.5
        )
    end
end

return M