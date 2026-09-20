local common = require("cyn.engine.resources.common")

---@class resource.video : resource_base
local M = {
    name = "",
    type = "video",
}

---Loads a video from a file.
---@param path string path to the video file.
---@return resource.video
function M.from_file(path)
    local name = common.get_typed_name("video", path)

    lstg.LoadVideo(name, path)

    local vid = MakeInstance(M)
    vid.name = name

    return vid
end

function M:destroy()
    lstg.RemoveResource(self._pool, "video", self.name)
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("video", self.name, true)
    return r == true
end

-------------- State

---Sets a video looping or not
---@param enabled boolean whether the video should loop at the end.
function M:set_loop(enabled)
    lstg.SetVideoLoop(self.name, enabled)
end

return M