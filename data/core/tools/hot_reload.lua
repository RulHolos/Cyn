---Watches all mounted roots and react to file changes.
---
---.lua files that were required are re-loading using DoFile. Resulted tables are merged into the original table object returned by require.
---
---.cdf files are validated using core.cdf.invalidate. Any subsequent access to them will get fresh data.
---
---Any other file triggers core.hot_reload.on_change events.
---
---Files loaded by lstg.DoFile are NOT tracked. Loaded files must be tracked in package.loaded for them to be able to be hot-reloaded.
---
---Any module registering itself into a named registry at top-level (understand, objects definitions) must make that registration idempotently (replace-by-name).
---
---Note: This system does NOT guard against crashes. You want your game to crash if you want to fix it.
---
---<b>WARNING: This system is extremely janky. Use at your own risks (but let's be real, what are the REAL risks here, it's not like you'll lose data)</b>
---@class core.hot_reload
local M = {
    enabled = true,
    roots = { "data", "assets", "i18n" },
    --Matching (with lua patterns) with canonical path. Matching files/dirs are ignored.
    exclude = {
        "^userdata/",
        "^logs/",
        "%.git/",
    },
}
core.hot_reload = M

local FileSystemWatcher = require("lstg.FileSystemWatcher")

local ACTION_NAMES = {
    [1] = "added",
    [2] = "removed",
    [3] = "modified",
    [4] = "renamed_old_name",
    [5] = "renamed_new_name",
}

---@type table<string, lstg.FileSystemWatcher>
local watchers = {}
---@type {pattern:string, callback:fun(path:string, action:string)}[]
local subscribers = {}

---@param pattern string
---@param callback fun(path:string, action:string)
function M.on_change(pattern, callback)
    table.insert(subscribers, { pattern = pattern, callback = callback })
end

---@param pattern string
function M.exclude_path(pattern)
    table.insert(M.exclude, pattern)
end

local function is_excluded(path)
    for _, pattern in ipairs(M.exclude) do
        if path:find(pattern) then
            return true
        end
    end
    return false
end

--VSCode fuckery garbage code...
local DEBOUNCE_FRAMES = 20
local frame_counter = 0
---@type table<string, {action:string, since:number}>
local pending = {}

local function path_to_modname(path)
    local rel = path:match("^data/(.+)%.lua$")
    if not rel then
        return nil
    end
    return (rel:gsub("/", "."))
end

local function reload_lua_module(modname)
    local old = package.loaded[modname]
    package.loaded[modname] = nil

    local ok, result = pcall(require, modname)
    if not ok then
        package.loaded[modname] = old
        error(string.format("[hot_reload] Failed to reload '%s': %s", modname, tostring(result)))
    end

    if type(old) == "table" and type(result) == "table" and old ~= result then
        for k in pairs(old) do
            old[k] = nil
        end
        for k, v in pairs(result) do
            old[k] = v
        end
        setmetatable(old, getmetatable(result))

        if old.is_class then
            core.object.resync(old)
        end

        package.loaded[modname] = old
    end

    lstg.Log(LOG.DEBUG, string.format("[hot_reload] Reloaded Lua module '%s'", modname))
end

local function dispatch(path, action)
    lstg.Log(LOG.DEBUG, string.format("[hot_reload] %s (%s)", path, action))

    if action ~= "removed" and action ~= "renamed_old_name" then
        local modname = path_to_modname(path)
        if modname and package.loaded[modname] ~= nil then
            reload_lua_module(modname)
        elseif modname then
            lstg.Log(LOG.WARN, string.format("[hot_reload] '%s' was not loaded via require, cannot hot-reload it", modname))
        elseif path:match("%.cdf$") then
            core.cdf.invalidate((path:gsub("%.cdf$", "")))
        end
    end

    for _, sub in ipairs(subscribers) do
        if path:find(sub.pattern) then
            sub.callback(path, action)
        end
    end
end

local function poll_root(root_name, watcher)
    local info = {}
    while watcher:read(info) do
        local normalized = info.file_name:gsub("\\", "/") --You never know. Thanks windows for being such a shit OS.
        normalized = normalized:gsub("^" .. root_name .. "/", "")
        local canonical = root_name .. "/" .. normalized

        if not is_excluded(canonical) then
            pending[canonical] = { action = ACTION_NAMES[info.action] or "modified", since = frame_counter }
        end
    end
end

function M.poll()
    if not M.enabled or DEBUG == false then return end

    frame_counter = frame_counter + 1
    for root_name, watcher in pairs(watchers) do
        poll_root(root_name, watcher)
    end

    for path, entry in pairs(pending) do
        if frame_counter - entry.since >= DEBOUNCE_FRAMES then
            pending[path] = nil
            dispatch(path, entry.action)
        end
    end
end

local function start()
    for _, root_name in ipairs(M.roots) do
        if not watchers[root_name] then
            local watcher = FileSystemWatcher.create(root_name)
            if watcher then
                watchers[root_name] = watcher
                lstg.Log(LOG.DEBUG, string.format("[hot_reload] Watching '%s'", root_name))
            else
                lstg.Log(LOG.INFO, string.format("[hot_reload] Failed to watch '%s'", root_name))
            end
        end
    end
end

local function stop()
    for name, watcher in pairs(watchers) do
        watcher:close()
        watchers[name] = nil
    end
end

---Enables or disables hot-reloading
---@param enabled boolean
function M.set_enabled(enabled)
    M.enabled = enabled
    if enabled then
        start()
    else
        stop()
    end
end

function M.is_enabled()
    return M.enabled and DEBUG ~= false
end

start()

core.signals:Register("Hot Reload", "FrameFunc", M.poll, 1e9)
