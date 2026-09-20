---Resolves and loads the active game folder/zip, Settings/Userdata agnostic.
---
---Default behavior:
---1. Read the `game` field directly from the settings json file.
---2. If missing, look for a single folder/zip under `game/` with a root script and guess-load it.
---
---Bring your own settings system by overriding the resolver with `set_resolver`.
---@class cyn.game_loader
local M = {}

local GAME_DIR = "game/"
local ENTRY_SCRIPT = "root.lua"
local settings_file = "userdata/settings.json"

---Overrides the settings json path used by the default resolver.
---@param path string
function M.set_settings_file(path)
    settings_file = path
end

---Reads the `game` field from the settings.
---@return string?
function M.read_game_field_from_settings()
    local f = io.open(settings_file, "r")
    if not f then
        return nil
    end
    local content = f:read("*a")
    f:close()

    local ok, data = pcall(json.deserialize, content)
    if not ok or type(data) ~= "table" then
        return nil
    end

    local game = data.game
    if type(game) == "string" and game ~= "" then
        return game
    end
    return nil
end

---Scans `game/` for a single loadable game (a folder with root.lua, or a zip). Errors if ambiguous.
---@return string?
function M.guess_game()
    lstg.FileManager.CreateDirectory(GAME_DIR)
    local list = lstg.FileManager.EnumFiles(GAME_DIR)
    local candidates = {}

    for _, v in ipairs(list) do
        local path, is_dir = v[1], v[2]
        if is_dir then
            if lstg.FileManager.FileExist(path .. ENTRY_SCRIPT) then
                table.insert(candidates, string.sub(path, string.len(GAME_DIR) + 1, -2))
            end
        elseif string.sub(path, -4) == ".zip" then
            table.insert(candidates, string.sub(path, string.len(GAME_DIR) + 1, -5))
        end
    end

    if #candidates == 0 then
        return nil
    elseif #candidates > 1 then
        error(("multiple candidate games found in '%s' (%s). Set the 'game' field in your settings to disambiguate.")
            :format(GAME_DIR, table.concat(candidates, ", ")))
    end

    return candidates[1]
end

---@type fun(): string?
local resolver = function()
    return M.read_game_field_from_settings() or M.guess_game()
end

---Overrides how the game name is resolved.
---
---Use this to plug in a custom settings/userdata system.
---@param fn fun(): string?
function M.set_resolver(fn)
    resolver = fn
end

---Resolves and loads the active game's root script.
function M.load()
    local name = resolver()
    if not name or name == "" then
        error("could not resolve which game to load (no 'game' field and no unambiguous folder/zip in 'game/').")
    end

    local zip_path = string.format("%s%s.zip", GAME_DIR, name)
    local dir_path = string.format("%s%s/", GAME_DIR, name)
    local dir_root_script = dir_path .. ENTRY_SCRIPT

    if lstg.FileManager.FileExist(zip_path) then
        lstg.LoadPack(zip_path)
        lstg.DoFile(ENTRY_SCRIPT)
    elseif lstg.FileManager.FileExist(dir_root_script) then
        lstg.FileManager.AddSearchPath(dir_path)
        lstg.DoFile(ENTRY_SCRIPT)
    else
        error(("resolved game '%s' but found neither '%s' nor '%s'."):format(name, zip_path, dir_root_script))
    end
end

return M
