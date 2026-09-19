---@class cyn.i18n
local M = {
    current_lang = nil,
    cdf = require("cyn.presentation.cdf")
}

---@param lang_code string 2-letter language code (e.g. "en", "fr", "es")
function M.set_lang(lang_code)
    M.current_lang = lang_code
    M.loaded_files = {}
    M.cached_strings = {}
    collectgarbage("collect")
end

---@return string
local function get_i18n_path(relative_path)
    return string.format("i18n/%s/%s", M.current_lang, relative_path)
end

function M.load_file(relative_path)
    return M.cdf.load_file(get_i18n_path(relative_path))
end

---@param relative_path string The relative path to the i18n file (without language prefix nor extension)
---@param block_id string|integer|table The block's name (from `Type:name`, a positional index, or an index path)
---@param key string The key of the property inside the block
---@param ... any Arguments to format the string if it contains placeholders
---@return string @The localized formatted string.
---@overload fun(relative_path:string, block_id:integer, key:string) : string
function M.get(relative_path, block_id, key, ...)
    relative_path = get_i18n_path(relative_path)

    local lookup_key = M.cdf.cache_key(relative_path, block_id, key)
    local str = M.cdf.cached_strings[lookup_key]

    if not str then
        local block = M.cdf.get_block(relative_path, block_id)

        if not block or block[key] == nil then
            return string.format("[%s -> %s.%s missing]", relative_path, tostring(block_id), key)
        end

        str = block[key]
        M.cdf.cached_strings[lookup_key] = str
    end

    if select("#", ...) == 0 then
        return str
    end

    return string.format(str, ...)
end

M.set_lang("en")

return M