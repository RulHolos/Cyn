---@param file_path string
---@return boolean
local function isFileNameZip(file_path)
    if string.len(file_path) < 4 then
        return false
    end

    return string.sub(file_path, -4) == ".zip" or string.sub(file_path, -4) == ".rar"
end

-------------------------------------------------------------------

---@class core.plugins
core.plugins = {}

local PLUGINS_PATH = "plugins/"
local ENTRY_POINT_SCRIPT = "init.lua"

---@return core.plugins.config.entry[]
function core.plugins.ListPlugins()
    local list = lstg.FileManager.EnumFiles(PLUGINS_PATH)
    local result = {}
    local seen_names = {}

    for _, v in ipairs(list) do
        local path = v[1]
        local name, directory_mode

        if v[2] then
            if lstg.FileManager.FileExist(path .. ENTRY_POINT_SCRIPT) then
                name = string.sub(path, string.len(PLUGINS_PATH) + 1, -2)
                directory_mode = true
            end
        elseif isFileNameZip(path) then
            lstg.LoadPack(path)
            local file_exists = lstg.FileManager.GetArchive(path):FileExist(ENTRY_POINT_SCRIPT)
            lstg.UnloadPack(path)

            if file_exists then
                name = string.sub(path, string.len(PLUGINS_PATH) + 1, -5)
                directory_mode = false
            end
        end

        if name then
            if seen_names[name] then
                lstg.Log(LOG.ERROR, string.format("plugin name conflict: '%s' is not unique (folder and zip with the same name?)", name))
            end
            seen_names[name] = true

            table.insert(result, {
                name = name,
                path = path,
                directory_mode = directory_mode,
                enable = true,
            })
        end
    end

    return result
end

---@param entry core.plugins.config.entry
---@return boolean
function core.plugins.LoadPlugin(entry)
    local ok, err

    if entry.directory_mode then
        lstg.FileManager.AddSearchPath(entry.path)
        ok, err = pcall(lstg.DoFile, entry.path .. ENTRY_POINT_SCRIPT)
    else
        lstg.LoadPack(entry.path)
        ok, err = pcall(lstg.DoFile, ENTRY_POINT_SCRIPT, entry.path)
    end

    if not ok then
        lstg.Log(LOG.ERROR, string.format("plugin '%s' failed to load: %s", entry.name, tostring(err)))
        return false
    end

    return true
end

-------------------------------------------------------------------

local CONFIG_FILE = "plugins.json"

---@class core.plugins.config.entry
local _ = {
    name = "",
    path = "",
    directory_mode = false,
    enable = false,
}

local function checkDirectory()
    lstg.FileManager.CreateDirectory(PLUGINS_PATH)
end

---@return core.plugins.config.entry
function core.plugins.LoadConfig()
    checkDirectory()

    local f = io.open(PLUGINS_PATH .. CONFIG_FILE, "rb")
    if not f then
        return {}
    end

    local src = f:read("*a")
    f:close()

    local ok, val = pcall(json.deserialize, src)
    if not ok then
        lstg.Log(LOG.ERROR, string.format("load json '%s' failed: %s", PLUGINS_PATH .. CONFIG_FILE, val))
        return {}
    end

    if type(val) ~= "table" then
        lstg.Log(LOG.ERROR, string.format("plugin config '%s' has an invalid format", PLUGINS_PATH .. CONFIG_FILE))
        return {}
    end

    return val
end

---@param cfg core.plugins.config.entry[]
function core.plugins.SaveConfig(cfg)
    checkDirectory()

    local f, msg = io.open(PLUGINS_PATH .. CONFIG_FILE, "wb")
    if not f then
        error(msg)
    end

    f:write(string.json_pretty(json.serialize(cfg)))
    f:close()
end

---@param cfg core.plugins.config.entry[]
---@return core.plugins.config.entry[]
function core.plugins.FreshConfig(cfg)
    local new_cfg = core.plugins.ListPlugins()

    if type(cfg) == "table" then
        local old_by_key = {}

        for _, v in ipairs(cfg) do
            local key = v.name .. "\0" .. v.path .. "\0" .. tostring(v.directory_mode)
            old_by_key[key] = v
        end

        for _, new_v in ipairs(new_cfg) do
            local key = new_v.name .. "\0" .. new_v.path .. "\0" .. tostring(new_v.directory_mode)
            local old_v = old_by_key[key]

            if old_v then
                new_v.enable = old_v.enable
            end
        end
    end

    return new_cfg
end

---@param cfg core.plugins.config.entry[]
function core.plugins.LoadPluginsByConfig(cfg)
    local loaded_count = 0
    local failed_count = 0

    for _, v in ipairs(cfg) do
        if v.enable then
            if core.plugins.LoadPlugin(v) then
                loaded_count = loaded_count + 1
            else
                failed_count = failed_count + 1
            end
        end
    end

    if failed_count > 0 then
        lstg.Log(LOG.INFO, string.format("plugin loading finished: %d loaded, %d failed", loaded_count, failed_count))
    end
end

---@param cfg core.plugins.config.entry[]
function core.plugins.PrintConfig(cfg)
    lstg.Print("========== Plugins ==========")
    for i, v in ipairs(cfg) do
        lstg.Print(tostring(i), v.name, v.path, v.directory_mode)
    end
    lstg.Print("=============================")
end

-------------------------------------------------------------------

function core.plugins.LoadPlugins()
    local config_ok, cfg = pcall(core.plugins.LoadConfig)
    if not config_ok then
        lstg.Log(LOG.ERROR, string.format("failed to load plugin config: %s", tostring(cfg)))
        cfg = {}
    end

    local scan_ok, new_cfg = pcall(core.plugins.FreshConfig, cfg)
    if not scan_ok then
        lstg.Log(LOG.ERROR, string.format("failed to enumerate plugins: %s", tostring(new_cfg)))
        return
    end

    local save_ok, save_err = pcall(core.plugins.SaveConfig, new_cfg)
    if not save_ok then
        lstg.Log(LOG.ERROR, string.format("failed to save plugin config: %s", tostring(save_err)))
    end

    core.plugins.LoadPluginsByConfig(new_cfg)
end