---@class core.userdata
---@field settings settings
local M = {}
core.userdata = M

local dir_root = "userdata"
local dir_screenshots = dir_root .. "/screenshots"
local dir_replays = dir_root .. "/replays"
local dir_db = dir_root .. "/db"

function M.CreateDirectories()
    lstg.FileManager.CreateDirectory(dir_root)
    lstg.FileManager.CreateDirectory(dir_screenshots)
    lstg.FileManager.CreateDirectory(dir_replays)
    lstg.FileManager.CreateDirectory(dir_db)
end

---@return string
function M.get_root_directory()
    return dir_root
end

---@return string
function M.get_snapshot_directory()
    return dir_screenshots
end

---@return string
function M.get_replay_directory()
    return dir_replays
end

---@return string
function M.get_database_directory()
    return dir_db
end

---@return string
function M.get_named_database_directory()
    return M.get_database_directory() .. "/" .. core.userdata.settings.game
end

function M.snapshot()
    local file_name = string.format("%s/%s.jpg", dir_screenshots, os.date("%Y-%m-%d_%H-%M-%S"))
    lstg.Snapshot(file_name)
end

M.CreateDirectories()
