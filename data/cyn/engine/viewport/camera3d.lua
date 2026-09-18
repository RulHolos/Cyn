---@class cyn.viewport.camera3d
local M = {
    _state = {
        eye = { 0, 0, -1 },
        at = { 0, 0, 0 },
        up = { 0, 1, 0 },
        fovy = math.pi / 2,
        depth = { 1, 2 },
        fog = { start = 0, finish = 0, color = lstg.Color(0x00000000) },
    }
}

function M:reset()
    self._state = {
        eye = { 0, 0, -1 },
        at = { 0, 0, 0 },
        up = { 0, 1, 0 },
        fovy = math.pi / 2,
        depth = { 1, 2 },
        fog = { start = 0, finish = 0, color = lstg.Color(0x00000000) },
    }
end

---Configures camera view. All fields are optional.
---@param cfg { eye:{x:number,y:number,z:number}?, at:{x:number,y:number,z:number}?, up:{x:number,y:number,z:number}?, fov:number?, depth:{near:number,far:number}?, fog:{start:number,finish:number,color:lstg.Color}? }
function M:set(cfg)
    local s = self._state

    if cfg.eye then
        s.eye = { cfg.eye.x, cfg.eye.y, cfg.eye.z }
    end

    if cfg.at then
        s.at = { cfg.at.x, cfg.at.y, cfg.at.z }
    end

    if cfg.up then
        s.up = { cfg.up.x, cfg.up.y, cfg.up.z }
    end

    if cfg.fov then
        s.fovy = cfg.fov
    end

    if cfg.depth then
        s.depth = { cfg.depth[1], cfg.depth[2] }
    end

    if cfg.fog then
        cfg.fog.color.a = 255
        s.fog = cfg.fog
    end
end

---Returns a COPY of the current camera state.
---@return table
function M:get()
    local s = self._state
    return {
        eye = { x = s.eye[1], y = s.eye[2], z = s.eye[3] },
        at = { x = s.at[1], y = s.at[2], z = s.at[3] },
        up = { x = s.up[1], y = s.up[2], z = s.up[3] },
        fov = s.fovy,
        depth = { near = s.depth[1], far = s.depth[2] },
        fog = { start = s.fog.start, finish = s.fog.finish, color = s.fog.color },
    }
end

return M
