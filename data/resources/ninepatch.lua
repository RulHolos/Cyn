---@class resource.ninepatch : resource_base
---@field margin_left number
---@field margin_right number
---@field margin_top number
---@field margin_bottom number
---@field border_left number?
---@field border_right number?
---@field border_top number?
---@field border_bottom number?
---@field repeat_edges boolean
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
    repeat_edges = false,
    ---@type BlendMode
    blendmode = "",
    -- Left, center, right
    _tl = "", _tc = "", _tr = "",
    _ml = "", _mc = "", _mr = "",
    _bl = "", _bc = "", _br = "",
    _cw = 0,
    _ch = 0,
    _tex_name = "",
}
resources.ninepatch = M

local _np_id = 0

local function make_piece_name(id, piece)
    return "np" .. id .. "_" .. piece
end

local function load_patches(id, tex_name, tw, th, ml, mr, mt, mb)
    local cw = tw - ml - mr
    local ch = th - mt - mb
    lstg.LoadImage(make_piece_name(id, "tl"), tex_name, 0, 0, ml, mt)
    lstg.LoadImage(make_piece_name(id, "tc"), tex_name, ml, 0, cw, mt)
    lstg.LoadImage(make_piece_name(id, "tr"), tex_name, tw - mr, 0, mr, mt)
    lstg.LoadImage(make_piece_name(id, "ml"), tex_name, 0, mt, ml, ch)
    lstg.LoadImage(make_piece_name(id, "mc"), tex_name, ml, mt, cw, ch)
    lstg.LoadImage(make_piece_name(id, "mr"), tex_name, tw - mr, mt, mr, ch)
    lstg.LoadImage(make_piece_name(id, "bl"), tex_name, 0, th - mb, ml, mb)
    lstg.LoadImage(make_piece_name(id, "bc"), tex_name, ml, th - mb, cw, mb)
    lstg.LoadImage(make_piece_name(id, "br"), tex_name, tw - mr, th - mb, mr, mb)
    return cw, ch
end

local function init_instance(np, id, tex_name, tw, th, ml, mr, mt, mb, repeat_edges)
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
    np.repeat_edges = repeat_edges or false
    np._tl = make_piece_name(id, "tl")
    np._tc = make_piece_name(id, "tc")
    np._tr = make_piece_name(id, "tr")
    np._ml = make_piece_name(id, "ml")
    np._mc = make_piece_name(id, "mc")
    np._mr = make_piece_name(id, "mr")
    np._bl = make_piece_name(id, "bl")
    np._bc = make_piece_name(id, "bc")
    np._br = make_piece_name(id, "br")
    np._cw, np._ch = load_patches(id, tex_name, tw, th, ml, mr, mt, mb)
    np._tex_name = tex_name
end

---Loads a ninepatch from a file.
---@param path string
---@param ml number
---@param mr number
---@param mt number
---@param mb number
---@param mipmap boolean? whether to generate mipmaps.
---@param repeat_edges boolean? If true, the stretching regions are tiled instead of stretched.
---@return resource.ninepatch
function M.from_file(path, ml, mr, mt, mb, mipmap, repeat_edges)
    local tex_name = resources.get_typed_name("tex", path)
    lstg.LoadTexture(tex_name, path, mipmap)
    if resources.default_sampler_state then
        lstg.SetTextureSamplerState(tex_name, resources.default_sampler_state)
    end
    local tw, th = lstg.GetTextureSize(tex_name)
    _np_id = _np_id + 1
    local np = makeInstance(M)
    init_instance(np, _np_id, tex_name, tw, th, ml, mr, mt, mb, repeat_edges)
    return np
end

---Loads a ninepatch from an existing image.
---@param img resource.image
---@param ml number
---@param mr number
---@param mt number
---@param mb number
---@param repeat_edges boolean? If true, the stretching regions are tiled instead of stretched.
---@return resource.ninepatch
function M.from_image(img, ml, mr, mt, mb, repeat_edges)
    local tex_name = "tex" .. img.name:sub(4)
    if resources.default_sampler_state then
        lstg.SetTextureSamplerState(tex_name, resources.default_sampler_state)
    end
    _np_id = _np_id + 1
    local np = makeInstance(M)
    init_instance(np, _np_id, tex_name, img.width, img.height, ml, mr, mt, mb, repeat_edges)
    return np
end

function M:destroy()
    local pool = self._pool
    for _, piece in ipairs({
        self._tl, self._tc, self._tr,
        self._ml, self._mc, self._mr,
        self._bl, self._bc, self._br,
    }) do
        lstg.RemoveResource(pool, "img", piece)
    end
end

---Gets the source texture dimensions.
---@return number width, number height
function M:get_size()
    return self.width, self.height
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("img", self._mc, true)
    return r == true
end

-------------- State

---@param blendmode BlendMode
function M:set_blendmode(blendmode)
    self.blendmode = blendmode
    for _, piece in ipairs({
        self._tl, self._tc, self._tr,
        self._ml, self._mc, self._mr,
        self._bl, self._bc, self._br,
    })
    do
        lstg.SetImageState(piece, blendmode)
    end
end

---@param color1 lstg.Color
function M:set_color(color1, color2, color3, color4)
    for _, piece in ipairs({
        self._tl, self._tc, self._tr,
        self._ml, self._mc, self._mr,
        self._bl, self._bc, self._br,
    })
    do
        lstg.SetImageState(piece, self.blendmode, color1)
    end
end

---@param blendmode BlendMode
---@param color lstg.Color?
function M:set(blendmode, color)
    self.blendmode = blendmode or self.blendmode
    for _, piece in ipairs({
        self._tl, self._tc, self._tr,
        self._ml, self._mc, self._mr,
        self._bl, self._bc, self._br,
    })
    do
        lstg.SetImageState(piece, self.blendmode, color)
    end
end

---@param enabled boolean
function M:set_repeat(enabled)
    self.repeat_edges = enabled
end

---Sets the rendered border sizes independently from the source margins.
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

-------------- Rendering helpers (repeat mode)
--- This assumes the screen is using "ui" view mode.

local function to_scissor(l, r, b, t)
    local sc = core.screen
    return l * sc.scale + sc.dx,
           r * sc.scale + sc.dx,
           b * sc.scale + sc.dy,
           t * sc.scale + sc.dy
end

local function restore_scissor()
    local sc = core.screen
    lstg.SetScissorRect(
        sc.dx,
        sc.width * sc.scale + sc.dx,
        sc.dy,
        sc.height * sc.scale + sc.dy
    )
end

local function tile_h(img_name, tw, rl, rr, rb, rt)
    lstg.SetScissorRect(to_scissor(rl, rr, rb, rt))
    local x = rl
    while x < rr do
        lstg.RenderRect(img_name, x, x + tw, rb, rt)
        x = x + tw
    end
    restore_scissor()
end

local function tile_v(img_name, th, rl, rr, rb, rt)
    lstg.SetScissorRect(to_scissor(rl, rr, rb, rt))
    local y = rb
    while y < rt do
        lstg.RenderRect(img_name, rl, rr, y, y + th)
        y = y + th
    end
    restore_scissor()
end

local function tile_2d(img_name, tw, th, rl, rr, rb, rt)
    lstg.SetScissorRect(to_scissor(rl, rr, rb, rt))
    local y = rb
    while y < rt do
        local x = rl
        while x < rr do
            lstg.RenderRect(img_name, x, x + tw, y, y + th)
            x = x + tw
        end
        y = y + th
    end
    restore_scissor()
end

-------------- Rendering

---Renders the ninepatch with specified coordinates
---@param left number
---@param right number
---@param bottom number
---@param top number
function M:render_rect(left, right, bottom, top)
    local L, R, B, T = left, right, bottom, top
    local bl = self.border_left or self.margin_left
    local br = self.border_right or self.margin_right
    local bt = self.border_top or self.margin_top
    local bb = self.border_bottom or self.margin_bottom

    lstg.RenderRect(self._tl, L, L + bl, T - bt, T)
    lstg.RenderRect(self._tr, R - br, R, T - bt, T)
    lstg.RenderRect(self._bl, L, L + bl, B, B + bb)
    lstg.RenderRect(self._br, R - br, R, B, B + bb)

    if self.repeat_edges then
        tile_h(self._tc, self._cw, L + bl, R - br, T - bt, T)
        tile_h(self._bc, self._cw, L + bl, R - br, B, B + bb)
        tile_v(self._ml, self._ch, L, L + bl, B + bb, T - bt)
        tile_v(self._mr, self._ch, R - br, R, B + bb, T - bt)
        tile_2d(self._mc, self._cw, self._ch, L + bl, R - br, B + bb, T - bt)
    else
        lstg.RenderRect(self._tc, L + bl, R - br, T - bt, T)
        lstg.RenderRect(self._bc, L + bl, R - br, B, B + bb)
        lstg.RenderRect(self._ml, L, L + bl, B + bb, T - bt)
        lstg.RenderRect(self._mr, R - br, R, B + bb, T - bt)
        lstg.RenderRect(self._mc, L + bl, R - br, B + bb, T - bt)
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