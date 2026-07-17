---@class core.userdata
---@field settings settings
local M = {}
core.userdata = M
---@type table<string, any> Table for abritrary game state variables. Like score or player power. Will be kept between stages. Will reset with new stage groups.
core.userdata.gamestate = {
    score = 0,
    hiscore = 0,
    lives = 2,
    bombs = 2,
}

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

---@param amount number Points to add
---@param update_hiscore boolean? Whether to update hiscore (default: true)
function M.add_score(amount, update_hiscore)
    local gs = core.userdata.gamestate
    gs.score_target = (gs.score_target or gs.score) + amount
    if update_hiscore ~= false and gs.score_target > gs.hiscore then
        gs.hiscore = gs.score_target
    end
end

---Must be called every frame to animate the score display.
function M.tick_score()
    local gs = core.userdata.gamestate
    local target = gs.score_target or gs.score
    local cur = gs.score
    local diff = target - cur
    if diff <= 0 then
        gs.score = target
        return
    end
    local step
    if diff <= 100 then
        step = 10
    elseif diff <= 1000 then
        step = 100
    else
        step = math.floor(diff / 60) * 10
        step = math.max(step, 10)
    end
    gs.score = math.min(cur + step, target)
end
core.signals:Register("tick_score", "Frame", M.tick_score)

M.CreateDirectories()
