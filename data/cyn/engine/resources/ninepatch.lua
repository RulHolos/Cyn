local common = require("cyn.engine.resources.common")

---@class resource.ninepatch : resource_base
---@field margin_left number
---@field margin_right number
---@field margin_top number
---@field margin_bottom number
---@field border_left number?
---@field border_right number?
---@field border_top number?
---@field border_bottom number?
---@field flip_h boolean
---@field flip_v boolean
---@field tile_top boolean
---@field tile_bottom boolean
---@field tile_left boolean
---@field tile_right boolean
---@field tile_center boolean
local M = {
    name = "",
    type = "img",
    width = 0,
    height = 0,
    margin_left = 0,
    margin_right = 0,
    margin_top = 0,
    margin_bottom = 0,
    border_left = nil, ---@type number?
    border_right = nil, ---@type number?
    border_top = nil, ---@type number?
    border_bottom = nil, ---@type number?
    flip_h = false,
    flip_v = false,
    tile_top = false,
    tile_bottom = false,
    tile_left = false,
    tile_right = false,
    tile_center = false,
    ---@type BlendMode
    blendmode = "",
    ---9 sub-image names, row-major: TL TC TR / ML MC MR / BL BC BR
    ---@type string[]|nil
    _pieces = nil,
    _cw = 0,
    _ch = 0,
    _tex_name = "",
}

local _np_id = 0

local function make_piece_name(id, piece)
    return "np" .. id .. "_" .. piece
end

---Loads the 9 sub-images and returns them as a row-major array, plus the size of the stretchable center region.
local function load_patches(id, tex_name, tw, th, ml, mr, mt, mb)
    local cw = tw - ml - mr
    local ch = th - mt - mb

    local pieces = {
        make_piece_name(id, "tl"), make_piece_name(id, "tc"), make_piece_name(id, "tr"),
        make_piece_name(id, "ml"), make_piece_name(id, "mc"), make_piece_name(id, "mr"),
        make_piece_name(id, "bl"), make_piece_name(id, "bc"), make_piece_name(id, "br"),
    }

    lstg.LoadImage(pieces[1], tex_name, 0, 0, ml, mt)
    lstg.LoadImage(pieces[2], tex_name, ml, 0, cw, mt)
    lstg.LoadImage(pieces[3], tex_name, tw - mr, 0, mr, mt)
    lstg.LoadImage(pieces[4], tex_name, 0, mt, ml, ch)
    lstg.LoadImage(pieces[5], tex_name, ml, mt, cw, ch)
    lstg.LoadImage(pieces[6], tex_name, tw - mr, mt, mr, ch)
    lstg.LoadImage(pieces[7], tex_name, 0, th - mb, ml, mb)
    lstg.LoadImage(pieces[8], tex_name, ml, th - mb, cw, mb)
    lstg.LoadImage(pieces[9], tex_name, tw - mr, th - mb, mr, mb)

    return pieces, cw, ch
end

local function init_instance(np, id, tex_name, tw, th, ml, mr, mt, mb)
    np.name = "np" .. id
    np.width = tw
    np.height = th
    np.margin_left = ml
    np.margin_right = mr
    np.margin_top = mt
    np.margin_bottom = mb
    np.border_left = nil
    np.border_right = nil
    np.border_top = nil
    np.border_bottom = nil
    np.flip_h = false
    np.flip_v = false
    np.tile_top = false
    np.tile_bottom = false
    np.tile_left = false
    np.tile_right = false
    np.tile_center = false
    np._tex_name = tex_name

    local pieces, cw, ch = load_patches(id, tex_name, tw, th, ml, mr, mt, mb)
    np._pieces = pieces
    np._cw = cw
    np._ch = ch
end

---Loads a ninepatch from a file.
---@param path string
---@param ml number
---@param mr number
---@param mt number
---@param mb number
---@param mipmap boolean? whether to generate mipmaps.
---@return resource.ninepatch
function M.from_file(path, ml, mr, mt, mb, mipmap)
    local tex_name = common.get_typed_name("tex", path)
    lstg.LoadTexture(tex_name, path, mipmap)

    if common.default_sampler_state then
        lstg.SetTextureSamplerState(tex_name, common.default_sampler_state)
    end

    local tw, th = lstg.GetTextureSize(tex_name)
    _np_id = _np_id + 1

    local np = MakeInstance(M)
    init_instance(np, _np_id, tex_name, tw, th, ml, mr, mt, mb)

    return np
end

---Loads a ninepatch from an existing image.
---@param img resource.image
---@param ml number
---@param mr number
---@param mt number
---@param mb number
---@return resource.ninepatch
function M.from_image(img, ml, mr, mt, mb)
    local tex_name = "tex" .. img.name:sub(4)

    if common.default_sampler_state then
        lstg.SetTextureSamplerState(tex_name, common.default_sampler_state)
    end

    _np_id = _np_id + 1

    local np = MakeInstance(M)
    init_instance(np, _np_id, tex_name, img.width, img.height, ml, mr, mt, mb)

    return np
end

function M:destroy()
    local pool = self._pool
    local pieces = self._pieces
    if pieces == nil then
        return
    end

    for i = 1, 9 do
        lstg.RemoveResource(pool, "img", pieces[i])
    end
end

---Gets the source texture dimensions.
---@return number width, number height
function M:get_size()
    return self.width, self.height
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("img", self._pieces[5], true)
    return r == true
end

-------------- State

---Sets the blend mode and color of every piece.
---@param blendmode BlendMode
---@param color lstg.Color?
function M:set(blendmode, color)
    self.blendmode = blendmode or self.blendmode
    local pieces = self._pieces
    if pieces == nil then
        return
    end

    for i = 1, 9 do
        lstg.SetImageState(pieces[i], self.blendmode, color)
    end
end

---@param h boolean whether to mirror horizontally.
---@param v boolean whether to mirror vertically.
function M:set_flip(h, v)
    self.flip_h = h or false
    self.flip_v = v or false
end

---Sets which edges/center tile instead of stretch. Any omitted argument is treated as false, call this with all 5 values you want set.
---@param top boolean?
---@param right boolean?
---@param bottom boolean?
---@param left boolean?
---@param center boolean?
function M:set_tiling(top, right, bottom, left, center)
    self.tile_top = top or false
    self.tile_right = right or false
    self.tile_bottom = bottom or false
    self.tile_left = left or false
    self.tile_center = center or false
end

---Sets the rendered border sizes independently from the source margins.
---
---Pass nil for any value to fall back to the corresponding margin.
---@param bl number? Left border render size.
---@param br number? Right border render size.
---@param bt number? Top border render size.
---@param bb number? Bottom border render size.
function M:set_borders(bl, br, bt, bb)
    self.border_left = bl
    self.border_right = br
    self.border_top = bt
    self.border_bottom = bb
end

---Sets the sampler state of this image.
---@param sampler_state SamplerState
function M:set_sampler_state(sampler_state)
    lstg.SetTextureSamplerState(self._tex_name, sampler_state)
end

-------------- Rendering helpers
---These assume the screen is using "ui" view mode.

local screen = require("cyn.engine.viewport.screen")

local function to_scissor(l, r, b, t)
    local sc = screen
    return l * sc.scale + sc.dx,
           r * sc.scale + sc.dx,
           b * sc.scale + sc.dy,
           t * sc.scale + sc.dy
end

local function restore_scissor()
    local sc = screen
    lstg.SetScissorRect(
        sc.dx,
        sc.width * sc.scale + sc.dx,
        sc.dy,
        sc.height * sc.scale + sc.dy
    )
end

local function src_piece(pieces, row, col, fh, fv)
    if fv then
        row = 4 - row
    end

    if fh then
        col = 4 - col
    end

    return pieces[(row - 1) * 3 + col]
end

local function draw(img, x1, x2, y1, y2, fh, fv)
    if fh then
        x1, x2 = x2, x1
    end

    if fv then
        y1, y2 = y2, y1
    end

    lstg.RenderRect(img, x1, x2, y1, y2)
end

local function tile_h(img, tw, l, r, b, t, fh, fv)
    lstg.SetScissorRect(to_scissor(l, r, b, t))

    local x = l
    while x < r do
        draw(img, x, x + tw, b, t, fh, fv)
        x = x + tw
    end

    restore_scissor()
end

local function tile_v(img, th, l, r, b, t, fh, fv)
    lstg.SetScissorRect(to_scissor(l, r, b, t))

    local y = b
    while y < t do
        draw(img, l, r, y, y + th, fh, fv)
        y = y + th
    end

    restore_scissor()
end

local function tile_2d(img, tw, th, l, r, b, t, fh, fv)
    lstg.SetScissorRect(to_scissor(l, r, b, t))

    local y = b
    while y < t do
        local x = l
        while x < r do
            draw(img, x, x + tw, y, y + th, fh, fv)
            x = x + tw
        end
        y = y + th
    end

    restore_scissor()
end

-------------- Rendering

---Renders the ninepatch with specified coordinates.
---@param left number
---@param right number
---@param bottom number
---@param top number
function M:render_rect(left, right, bottom, top)
    local fh, fv = self.flip_h, self.flip_v
    local pieces = self._pieces

    local bl = self.border_left or self.margin_left
    local br = self.border_right or self.margin_right
    local bt = self.border_top or self.margin_top
    local bb = self.border_bottom or self.margin_bottom

    local lw = fh and br or bl
    local rw = fh and bl or br
    local th = fv and bb or bt
    local bh = fv and bt or bb

    local L, R, B, T = left, right, bottom, top
    local IL, IR, IB, IT = L + lw, R - rw, B + bh, T - th

    draw(src_piece(pieces, 1, 1, fh, fv), L, IL, IT, T, fh, fv)
    draw(src_piece(pieces, 1, 3, fh, fv), IR, R, IT, T, fh, fv)
    draw(src_piece(pieces, 3, 1, fh, fv), L, IL, B, IB, fh, fv)
    draw(src_piece(pieces, 3, 3, fh, fv), IR, R, B, IB, fh, fv)

    local top_img = src_piece(pieces, 1, 2, fh, fv)
    if self.tile_top then
        tile_h(top_img, self._cw, IL, IR, IT, T, fh, fv)
    else
        draw(top_img, IL, IR, IT, T, fh, fv)
    end

    local bottom_img = src_piece(pieces, 3, 2, fh, fv)
    if self.tile_bottom then
        tile_h(bottom_img, self._cw, IL, IR, B, IB, fh, fv)
    else
        draw(bottom_img, IL, IR, B, IB, fh, fv)
    end

    local left_img = src_piece(pieces, 2, 1, fh, fv)
    if self.tile_left then
        tile_v(left_img, self._ch, L, IL, IB, IT, fh, fv)
    else
        draw(left_img, L, IL, IB, IT, fh, fv)
    end

    local right_img = src_piece(pieces, 2, 3, fh, fv)
    if self.tile_right then
        tile_v(right_img, self._ch, IR, R, IB, IT, fh, fv)
    else
        draw(right_img, IR, R, IB, IT, fh, fv)
    end

    local center_img = src_piece(pieces, 2, 2, fh, fv)
    if self.tile_center then
        tile_2d(center_img, self._cw, self._ch, IL, IR, IB, IT, fh, fv)
    else
        draw(center_img, IL, IR, IB, IT, fh, fv)
    end
end

---Renders the ninepatch with specified coordinates and size. (centered on x,y)
---@param x number
---@param y number
---@param w number
---@param h number
function M:render(x, y, w, h)
    local hw, hh = w * 0.5, h * 0.5
    self:render_rect(x - hw, x + hw, y - hh, y + hh)
end

return M