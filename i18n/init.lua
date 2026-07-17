i18n = {
    current_lang = nil,
    ---@type core.cdf
    cdf = core.cdf
}

---@param lang_code string 2-letter language code (e.g. "en", "fr", "es")
function i18n.set_lang(lang_code)
    i18n.current_lang = lang_code
    i18n.loaded_files = {}
    i18n.cached_strings = {}
    collectgarbage("collect")
end

---@return string
local function get_i18n_path(relative_path)
    return string.format("i18n/%s/%s", i18n.current_lang, relative_path)
end

function i18n.load_file(relative_path)
    return i18n.cdf.load_file(get_i18n_path(relative_path))
end

---@param relative_path string The relative path to the i18n file (without language prefix nor extension)
---@param block_id string|integer|table The block's name (from `Type:name`, a positional index, or an index path
---@param key string The key of the property inside the block
---@param ... any Arguments to format the string if it contains placeholders
---@return string @The localized formatted string.
---@overload fun(relative_path:string, block_id:integer, key:string) : string
function i18n.get(relative_path, block_id, key, ...)
    relative_path = get_i18n_path(relative_path)

    local lookup_key = i18n.cdf.cache_key(relative_path, block_id, key)
    local str = i18n.cdf.cached_strings[lookup_key]

    if not str then
        local block = i18n.cdf.get_block(relative_path, block_id)

        if not block or block[key] == nil then
            return string.format("[%s -> %s.%s missing]", relative_path, tostring(block_id), key)
        end

        str = block[key]
        i18n.cdf.cached_strings[lookup_key] = str
    end

    if select("#", ...) == 0 then
        return str
    end

    return string.format(str, ...)
end

i18n.set_lang("en")