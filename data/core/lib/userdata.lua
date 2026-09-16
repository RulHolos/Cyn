---@class core.userdata
---@field settings core.settings
---@field scoredata table Scoredata database proxy.
local M = {}
core.userdata = M
---@type table<string, any> Table for abritrary game state variables. Like score or player power. Will be kept between stages. Will reset with new stage groups.
core.userdata.gamestate = {
    score = 0,
    hiscore = 0,
    lives = 2,
    bombs = 2,
}

local sqlite = require("sqlite")
local cjson = require("cjson")

local _tables = {}
local _dirty_tables = {}
local _proxy_cache = {}
---@type lstg.sqlite.Database?
local db = nil

local function sql_escape(str)
    return tostring(str):gsub("'", "''")
end

local function create_table_proxy(tbl_name)
    if _proxy_cache[tbl_name] then
        return _proxy_cache[tbl_name]
    end

    _tables[tbl_name] = _tables[tbl_name] or {}
    _dirty_tables[tbl_name] = _dirty_tables[tbl_name] or {}

    local proxy = {}
    local mt = {
        __index = function(_, k)
            local v = _tables[tbl_name][k]
            if type(v) == "table" then
                return v
            end
            local child_tbl_name = tbl_name .. "__" .. tostring(k)
            local child_proxy = create_table_proxy(child_tbl_name)
            _tables[tbl_name][k] = child_proxy
            _dirty_tables[tbl_name][k] = true
            return child_proxy
        end,
        __newindex = function(_, k, v)
            if type(v) == "table" then
                local child_tbl_name = tbl_name .. "__" .. tostring(k)
                local child_proxy = create_table_proxy(child_tbl_name)
                _tables[child_tbl_name] = {}
                _dirty_tables[child_tbl_name] = _dirty_tables[child_tbl_name] or {}

                for sub_k, sub_v in pairs(v) do
                    child_proxy[sub_k] = sub_v
                end

                _tables[tbl_name][k] = child_proxy
                _dirty_tables[tbl_name][k] = true
            else
                if _tables[tbl_name][k] ~= v then
                    _tables[tbl_name][k] = v
                    _dirty_tables[tbl_name][k] = true
                end
            end
        end,
        __pairs = function()
            return pairs(_tables[tbl_name])
        end,
        __tostring = function()
            return string.format("sqlite_table<%s>", tbl_name)
        end
    }
    proxy = setmetatable(proxy, mt)
    _proxy_cache[tbl_name] = proxy
    return proxy
end

---Proxy for scoredata[table_name][key]
---
---No support for direct assignments to the root table.
core.userdata.scoredata = setmetatable({}, {
    __index = function(_, tbl_name)
        return create_table_proxy(tbl_name)
    end,
    __newindex = function(_, tbl_name, v)
        local proxy = create_table_proxy(tbl_name)
        if type(v) == "table" then
            for k, val in pairs(v) do
                proxy[k] = val
            end
        else
            error(string.format("Cannot assign non-table value to root scoredata table '%s'", tostring(tbl_name)))
        end
    end
})

---Initializes the database and loads all tables into memory.
function M.init_scoredata()
    local path = M.get_named_database()
    local err, code
    db, err, code = sqlite.Database.open(path, sqlite.OPEN_READWRITE + sqlite.OPEN_CREATE)
    if not db then
        error(string.format("Failed to open score database: %s (code: %s)", err, code))
    end

    local existing_tables = {}
    db:exec("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';", function(_, cols)
        table.insert(existing_tables, cols[1])
        return sqlite.OK
    end)

    for _, tbl_name in ipairs(existing_tables) do
        _tables[tbl_name] = _tables[tbl_name] or {}
        _dirty_tables[tbl_name] = _dirty_tables[tbl_name] or {}
    end

    for _, tbl_name in ipairs(existing_tables) do
        local query = string.format("SELECT key, value FROM '%s';", sql_escape(tbl_name))
        db:exec(query, function(_, cols)
            local key = cols[1]
            local val_str = cols[2]

            if val_str:sub(1, 6) == "$tbl:" then
                local ref_name = val_str:sub(7)
                _tables[tbl_name][key] = create_table_proxy(ref_name)
            else
                local num = tonumber(val_str)
                if num ~= nil then
                    _tables[tbl_name][key] = num
                elseif val_str == "true" or val_str == "false" then
                    _tables[tbl_name][key] = (val_str == "true")
                else
                    _tables[tbl_name][key] = val_str
                end
            end

            return sqlite.OK
        end)
    end
end

---Flushes all dirty data from all tables to the database.
function M.flush_scoredata()
    if not db then
        return
    end

    local queries = { "BEGIN TRANSACTION;" }
    local has_changes = false

    for tbl_name, dirty_keys in pairs(_dirty_tables) do
        if next(dirty_keys) ~= nil then
            table.insert(queries, string.format([[
                CREATE TABLE IF NOT EXISTS '%s' (
                    key TEXT PRIMARY KEY,
                    value TEXT
                );
            ]], sql_escape(tbl_name)))

            for k, _ in pairs(dirty_keys) do
                has_changes = true
                local val = _tables[tbl_name][k]
                if val == nil then
                    table.insert(queries, string.format(
                        "DELETE FROM '%s' WHERE key = '%s';",
                        sql_escape(tbl_name),
                        sql_escape(k)
                    ))
                else
                    local serialized_val
                    if type(val) == "table" then
                        local child_tbl_name = tbl_name .. "__" .. tostring(k)
                        serialized_val = "$tbl:" .. child_tbl_name
                    else
                        serialized_val = tostring(val)
                    end

                    table.insert(queries, string.format(
                        "INSERT OR REPLACE INTO '%s' (key, value) VALUES ('%s', '%s');",
                        sql_escape(tbl_name),
                        sql_escape(k),
                        sql_escape(serialized_val)
                    ))
                end
            end
            _dirty_tables[tbl_name] = {}
        end
    end

    if not has_changes then
        return
    end

    table.insert(queries, "COMMIT;")
    local ok, err, code = db:exec(table.concat(queries, "\n"))
    if not ok then
        lstg.Log(3, string.format("Failed to flush scoredata: %s (code: %s)", err, code))
    end
end

---Closes the database.
function M.close_scoredata()
    if db then
        M.flush_scoredata()
        db:close()
        db = nil
    end
end

local dir_root = "userdata"
local dir_screenshots = dir_root .. "/screenshots"
local dir_replays = dir_root .. "/replays"

function M.CreateDirectories()
    lstg.FileManager.CreateDirectory(dir_root)
    lstg.FileManager.CreateDirectory(dir_screenshots)
    lstg.FileManager.CreateDirectory(dir_replays)
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

---Returns the score database for the current running game/script.
---@return string
function M.get_named_database()
    return dir_root .. "/" .. core.userdata.settings.game .. ".db"
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
core.signals:Register("tick_score", "FrameFunc", M.tick_score)

core.signals:Register("flush_scoredata", "GameExit", function()
    M.flush_scoredata()
    M.close_scoredata()
end)

require("core.lib.settings")

M.CreateDirectories()
M.init_scoredata()
