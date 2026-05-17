---@class resource.video : resource_base
local M = {
    name = "",
    type = "video",
}
resources.video = M

---Loads a video from a file.
---@param path string path to the video file.
---@return resource.video
function M.from_file(path)
    local name = resources.get_typed_name("video", path)

    lstg.LoadVideo(name, path)

    local vid = makeInstance(M)
    vid.name = name

    return vid
end

function M:destroy()
    lstg.RemoveResource(lstg.GetResourceStatus(), "video", self.name)
end

---@return boolean
function M:is_valid()
    local r = lstg.CheckNamedRes("video", self.name, true)
    return r == true
end

-------------- State

