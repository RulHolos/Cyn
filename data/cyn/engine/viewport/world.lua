---@class cyn.viewport.world.data
---@field l number
---@field r number
---@field b number
---@field t number
---@field boundl number
---@field boundr number
---@field boundb number
---@field boundt number
---@field scrl number
---@field scrr number
---@field scrb number
---@field scrt number
---@field pl number
---@field pr number
---@field pb number
---@field pt number
---@field world integer

---Converts a table into raw world.
---@param cfg table { player, bound, scroll, mask }
---@return cyn.viewport.world.data
local function build_world(cfg)
    local pw, ph = cfg.play.w, cfg.play.h
    local sw, sh = cfg.scroll.w, cfg.scroll.h
    local b = cfg.bound
    local s = cfg.scroll

    return {
        l = -sw * 0.5, r = sw * 0.5,
        b = -sh * 0.5, t = sh * 0.5,
        boundl = -pw * 0.5 - b, boundr = pw * 0.5 + b,
        boundb = -ph * 0.5 - b, boundt = ph * 0.5 + b,
        scrl = s.x, scrr = s.x + s.w,
        scrb = s.y, scrt = s.y + s.h,
        pl = -pw * 0.5, pr = pw * 0.5,
        pb = -ph * 0.5, pt = ph * 0.5,
        world = cfg.mask,
    }
end

local _WORLD_DEFAULT = {
    play = { x = 0, y = 0, w = 384, h = 448 - 16 },
    bound = 32,
    scroll = { x = 32, y = 16, w = 384, h = 448 },
    mask = 0xFFFF,
}

---@class cyn.viewport.world
local M = {
    ---@private
    _default = {
        play = { x = 0, y = 0, w = 384 - 16, h = 448 - 16 },
        bound = 32,
        scroll = { x = 32, y = 16, w = 384, h = 448 },
        mask = 0xFFFF,
    },
    ---@type cyn.viewport.world.data
    data = build_world(_WORLD_DEFAULT)
}

local function copy_config(cfg)
    local copy = {}

    for k, v in pairs(cfg) do
        if type(v) == "table" then
            local nested = {}
            for kk, vv in pairs(v) do
                nested[kk] = vv
            end
            copy[k] = nested
        else
            copy[k] = v
        end
    end

    return copy
end

---Rebuilds self.data from the current default and re-applies the bound.
function M:reset()
    self.data = build_world(self._default)
    lstg.SetBound(self.data.boundl, self.data.boundr, self.data.boundb, self.data.boundt)
end

---Resets the default world layout itself back to the module's built-in default, then applies it.
function M:hard_reset()
    self._default = copy_config(_WORLD_DEFAULT)
    self:reset()
end

---Applies a new world layout immediately. (NOTE: Does not change defaults)
---
---Use `cyn.world:set_default()` if you want to survive a world reset.
---@param cfg { play:{x:number,y:number,w:number,h:number}, bound:number, scroll:{x:number,y:number,w:number,h:number}, mask:number? }
function M:apply(cfg)
    cfg.bound = cfg.bound or 32
    cfg.mask = cfg.mask or 0xFFFF
    cfg.scroll = cfg.scroll or { x = cfg.play.x, y = cfg.play.y, w = cfg.play.w, h = cfg.play.h }

    local w = build_world(cfg)
    for k, v in pairs(w) do
        self.data[k] = v
    end

    lstg.SetBound(self.data.boundl, self.data.boundr, self.data.boundb, self.data.boundt)
end

---Changes the default world layout. Survives world resets.
---@param cfg { play:{x:number,y:number,w:number,h:number}, bound:number, scroll:{x:number,y:number,w:number,h:number}, mask:number? }
function M:set_default(cfg)
    cfg.bound = cfg.bound or 32
    cfg.mask = cfg.mask or 0xFFFF
    cfg.scroll = cfg.scroll or { x = cfg.play.x, y = cfg.play.y, w = cfg.play.w, h = cfg.play.h }
    self._default = cfg
end

---Returns a COPY of the current world data.
---
---Only use this when you don't want to modify the actual world data directly.
---@return cyn.viewport.world.data
function M:get()
    local copy = {}
    for k, v in pairs(self.data) do
        copy[k] = v
    end
    return copy
end

---Returns a COPY of the default world layout.
---
---Only use this when you don't want to modify the actual default world layout directly.
---@return cyn.viewport.world.data
function M:get_default()
    return copy_config(self._default)
end

return M