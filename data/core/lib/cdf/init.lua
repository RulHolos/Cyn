---@class core.cdf.file<T>
---@field data T Parsed CDF data.
---@field _map table<string, table> Named CDF blocks.

---@class core.cdf
core.cdf = {
    loaded_files = {},
    cached_strings = {},
    ---@type table<string, fun(relative_path:string)[]>
    change_listeners = {},
    ---@type core.cdf.parser
    parser = require("core.lib.cdf.parser")
}

function core.cdf.cache_key(relative_path, block_id, key)
    return string.format("%s|%s|%s", relative_path, tostring(block_id), key)
end

local function index_nodes(file_container, node)
    for _, v in pairs(node) do
        if type(v) == "table" then
            if v._name then
                file_container._map[v._name] = v
            end
            index_nodes(file_container, v)
        end
    end
    return file_container
end

---@param relative_path string
---@return core.cdf.file
function core.cdf.load_file(relative_path)
    relative_path = string.format("%s.cdf", relative_path)

    if core.cdf.loaded_files[relative_path] then
        return core.cdf.loaded_files[relative_path]
    end

    local raw_data, err = core.cdf.parser.parse_file(relative_path)

    if err then
        lstg.Log(LOG.ERROR, "[CDF]: " .. err)
        core.cdf.loaded_files[relative_path] = { data = {}, _map = {} }
        return core.cdf.loaded_files[relative_path]
    end

    local file_container = {
        data = raw_data,
        _map = {},
    }

    file_container = index_nodes(file_container, raw_data)

    core.cdf.loaded_files[relative_path] = file_container
    return file_container
end

function core.cdf.get_block(relative_path, id_or_index)
    local file = core.cdf.load_file(relative_path)

    if type(id_or_index) == "table" then
        local current_node = file.data
        for _, index in ipairs(id_or_index) do
            if current_node and current_node[index] then
                current_node = current_node[index]
            else
                return nil
            end
        end
        return current_node
    elseif type(id_or_index) == "number" then
        return file.data[id_or_index]
    elseif type(id_or_index) == "string" then
        if file._map[id_or_index] then
            return file._map[id_or_index]
        end

        local segments = {}
        for segment in id_or_index:gmatch("[^/]+") do
            table.insert(segments, segment)
        end

        if #segments > 0 then
            local function navigate(nodes, segment_index)
                local segment = segments[segment_index]

                local target_type, target_name = segment:match("^([%w_]+):([%w_]+)$")
                if not target_type then
                    for _, node in ipairs(nodes) do
                        if type(node) == "table" and node._name == segment then
                            if segment_index == #segments then
                                return node
                            end
                            local found = navigate(node, segment_index + 1)
                            if found then return found end
                        end
                    end
                    target_type = segment
                end

                for _, node in ipairs(nodes) do
                    if type(node) == "table" and node._type == target_type then
                        if not target_name or node._name == target_name then
                            if segment_index == #segments then
                                return node
                            end
                            local found = navigate(node, segment_index + 1)
                            if found then return found end
                        end
                    end
                end
                return nil
            end

            return navigate(file.data, 1)
        end

        return nil
    end
end

local function navigate(segments, nodes, segment_index)
    local segment = segments[segment_index]

    local target_type, target_name = segment:match("^([%w_]+):([%w_]+)$")
    if not target_type then
        for _, node in ipairs(nodes) do
            if type(node) == "table" and node._name == segment then
                if segment_index == #segments then
                    return node
                end
                local found = navigate(segments, node, segment_index + 1)
                if found then return found end
            end
        end
        target_type = segment
    end

    for _, node in ipairs(nodes) do
        if type(node) == "table" and node._type == target_type then
            if not target_name or node._name == target_name then
                if segment_index == #segments then
                    return node
                end
                local found = navigate(segments, node, segment_index + 1)
                if found then return found end
            end
        end
    end
    return nil
end

---@param relative_path string The relative path to the cdf file (without extension)
---@param type_path string A slash-separated path of block names (e.g. "Dialogs/Stage/Sequence")
---@return table|nil @The matched block node, or nil if the path does not exist.
function core.cdf.get_path(relative_path, type_path)
    local file = core.cdf.load_file(relative_path)

    local segments = {}
    for segment in type_path:gmatch("[^/]+") do
        table.insert(segments, segment)
    end

    return navigate(segments, file.data, 1)
end

---Discards cached data for a cdf file so the next access reparses it from disk, then
---notifies any listener registered via `core.cdf.on_change`. Used by the hot-reload system.
---@param relative_path string The relative path to the cdf file (without extension)
function core.cdf.invalidate(relative_path)
    core.cdf.loaded_files[string.format("%s.cdf", relative_path)] = nil

    local prefix = relative_path .. "|"
    for key in pairs(core.cdf.cached_strings) do
        if key:sub(1, #prefix) == prefix then
            core.cdf.cached_strings[key] = nil
        end
    end

    local listeners = core.cdf.change_listeners[relative_path]
    if listeners then
        for _, callback in ipairs(listeners) do
            callback(relative_path)
        end
    end
end

---Registers a callback invoked whenever `relative_path` is reloaded via `core.cdf.invalidate`.
---@param relative_path string The relative path to the cdf file (without extension)
---@param callback fun(relative_path:string)
function core.cdf.on_change(relative_path, callback)
    local listeners = core.cdf.change_listeners[relative_path]
    if not listeners then
        listeners = {}
        core.cdf.change_listeners[relative_path] = listeners
    end
    table.insert(listeners, callback)
end

---Like `core.cdf.cast`, but keeps the resulting object up to date: it's automatically recasted in place whenever `relative_path` is hot-reloaded.
---@param relative_path string The relative path to the cdf file (without extension)
---@param block_id string|integer|table The block's name (from `Type:name`, a positional index, or an index path)
---@param class_or_obj table|function|nil The target object to populate, or a instantiator function. If nil, creates a flat table.
---@return table|nil @The populated game object container, kept in sync with the source file.
function core.cdf.bind(relative_path, block_id, class_or_obj)
    local obj = core.cdf.cast(core.cdf.get_block(relative_path, block_id), class_or_obj)
    if obj then
        core.cdf.on_change(relative_path, function()
            core.cdf.cast(core.cdf.get_block(relative_path, block_id), obj)
        end)
    end
    return obj
end


---@param block table|nil The parsed block node from the cdf structure
---@param class_or_obj table|function|nil The target object to populate, or a instantiator function. If nil, creates a flat table.
---@return table|nil @The populated game object container
function core.cdf.cast(block, class_or_obj)
    if not block then return nil end

    local obj
    if type(class_or_obj) == "function" then
        obj = class_or_obj() or {}
    else
        obj = class_or_obj or {}
    end

    for k, v in pairs(block) do
        if type(k) == "string" and k:sub(1, 1) ~= "_" then
            obj[k] = v
        end
    end

    return obj
end