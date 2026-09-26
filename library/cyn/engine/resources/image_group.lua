local common = require("cyn.engine.resources.common")

---@class resource.image_group : resource_base
---@field images resource.image[] Flat array of images in this group, 1-indexed.
---@field count integer Number of images in the group.
local M = {
    type = "imggrp",
    images = {},
    count = 0,
}

---Wraps an existing array of images into a group.
---@param images resource.image[]
---@return resource.image_group
function M.from_array(images)
    local group = MakeInstance(M)
    group.images = images
    group.count = #images
    return group
end

-------------- Access

---Returns the image at the given index.
---@param index integer
---@return resource.image
function M:get(index)
    return self.images[index]
end

---Returns a uniformly random image from the group.
---@return resource.image
function M:get_random()
    local index = math.random(1, self.count)
    return self.images[index]
end

---Returns the underlying flat array, for cases needing raw iteration.
---@return resource.image[]
function M:get_all()
    return self.images
end

-------------- Bulk operations

---Applies the same collision box to every image in the group.
---@param a number Collision width.
---@param b number? Collision height (defaults to `a`).
---@param rect boolean? Use rectangular collision.
function M:set_collision(a, b, rect)
    local col_b = b or a
    local col_rect = rect or false

    for i = 1, self.count do
        local img = self.images[i]
        img.a = a
        img.b = col_b
        img.rect = col_rect
    end
end

---Calls a method by name on every image in the group, forwarding extra arguments.
---@param method_name string
---@param ... any
function M:call_all(method_name, ...)
    for i = 1, self.count do
        local img = self.images[i]
        img[method_name](img, ...)
    end
end

---Sets the scale of this image group.
---This scale will be applied to all rendering operations WITH hscale and vscale.
---@param scale number
---@return self
function M:set_scale(scale)
    for i = 1, self.count do
        local img = self.images[i]
        lstg.SetImageScale(img.name, scale)
    end
    return self
end

---@param blendmode BlendMode
---@return self
function M:set_blendmode(blendmode)
    self.blendmode = blendmode
    for i = 1, self.count do
        local img = self.images[i]
        lstg.SetImageState(img.name, blendmode)
    end
    return self
end

---Changes the color of the image group.
---@param color1 lstg.Color
---@param color2 lstg.Color?
---@param color3 lstg.Color?
---@param color4 lstg.Color?
---@return self
function M:set_color(color1, color2, color3, color4)
    for i = 1, self.count do
        local img = self.images[i]
        lstg.SetImageState(img.name, self.blendmode, color1, color2 or color1, color3 or color1, color4 or color1)
    end
    return self
end

---Destroys every image resource in the group and clears it.
function M:destroy()
    for i = 1, self.count do
        local img = self.images[i]
        lstg.RemoveResource(img._pool, "img", img.name)
    end

    self.images = {}
    self.count = 0
end

return M