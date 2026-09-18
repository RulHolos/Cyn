---@class core.cdf.parser
local parser = {}

--#region paths

local function dirname(path)
    return path:match("^(.*)/[^/]+$") or "."
end

local function normalize_path(path)
    local is_absolute = path:sub(1, 1) == "/"
    local parts = {}
    for segment in path:gmatch("[^/]+") do
        if segment == ".." then
            if #parts > 0 and parts[#parts] ~= ".." then
                table.remove(parts)
            else
                table.insert(parts, segment)
            end
        elseif segment ~= "." then
            table.insert(parts, segment)
        end
    end
    return (is_absolute and "/" or "") .. table.concat(parts, "/")
end

--#endregion
--@region Value casting

local function cast_value(val)
    if val == "true" then return true end
    if val == "false" then return false end
    if tonumber(val) then return tonumber(val) end

    local quoted = val:match('^"(.*)"$')
    if quoted then return quoted end

    --Lua call expressions. (e.g lstg.Color(255, 255, 255, 255))
    --Kept as raw. TODO: runtime loader to compile it.
    if val:match("^[%a_][%w_.]*%s*%(.*%)$") then
        return { __lua_expr = val }
    end

    return val
end

--#endregion
--#region Reference resolution

local resolve_namespace_ref

local function resolve_refs(str, stack, id_map, namespaces, namespace_overrides)
    --{#id.key}, lookup by id anywhere in the file
    str = str:gsub("{#([%w_]+)%.([%w_]+)}", function(id, key)
        local target = id_map[id]
        if not target or target[key] == nil then
            return string.format("{unresolved:#%s.%s}", id, key)
        end
        return tostring(target[key])
    end)

    --{.key} / {..key} / ... , N levels up the ancestor chain
    str = str:gsub("{(%.+)([%w_]+)}", function(dots, key)
        local levels = #dots
        local ancestor = stack[#stack - levels]
        if not ancestor or ancestor[key] == nil then
            return string.format("{unresolved:%s%s}", dots, key)
        end
        return tostring(ancestor[key])
    end)

    --{key}, zero dots, the current block's own property
    str = str:gsub("{([%w_]+)}", function(key)
        local current = stack[#stack]
        if not current or current[key] == nil then
            return string.format("{unresolved:%s}", key)
        end
        return tostring(current[key])
    end)

    --{Alias.Type.key}, lookup field on namespace
    str = str:gsub("{([%w_]+)%.([%w_]+)%.([%w_]+)}", function(alias, ty, key)
        local target = resolve_namespace_ref(alias .. "." .. ty, namespaces, namespace_overrides)
        if not target or target[key] == nil then
            return string.format("{unresolved:%s.%s.%s}", alias, ty, key)
        end
        return tostring(target[key])
    end)

    return str
end

--#endregion
--#region Arrays

local function split_array_items(inner)
    if inner:match("^%s*$") then return {} end

    local items = {}
    local buf = {}
    local in_quotes = false

    for idx = 1, #inner do
        local c = inner:sub(idx, idx)
        if c == '"' then
            in_quotes = not in_quotes
            table.insert(buf, c)
        elseif c == "," and not in_quotes then
            table.insert(items, table.concat(buf))
            buf = {}
        else
            table.insert(buf, c)
        end
    end
    table.insert(items, table.concat(buf))

    return items
end

local function parse_array(value_str)
    local inner = value_str:match("^%[(.*)%]$")
    if not inner then return nil end

    local items = {}
    for _, raw_item in ipairs(split_array_items(inner)) do
        local item = raw_item:gsub("^%s*(.-)%s*$", "%1")
        if item ~= "" then
            table.insert(items, cast_value(item))
        end
    end
    return items
end

--#endregion
--#region Comments

local function strip_inline_comment(line)
    local in_quotes = false
    local i = 1
    while i < #line do
        local c = line:sub(i, i)
        if c == '"' then
            in_quotes = not in_quotes
        elseif not in_quotes then
            local two = line:sub(i, i + 1)
            if two == "//" or two == "--" then
                return line:sub(1, i - 1)
            end
        end
        i = i + 1
    end
    return line
end

--#endregion
--#region Passes

local function parse_block_header(text)
    local head, extends_ref = text:match("^(.-)%s*|%s*(%S+)$")
    head = head or text

    local block_type, block_name = head:match("^([%w_.]+):([%w_]+)$")
    if not block_type then
        block_type = head:match("^([%w_.]+)$")
    end
    if not block_type then return nil end

    return { type = block_type, name = block_name, extends_ref = extends_ref }
end

function resolve_namespace_ref(ref, namespaces, namespace_overrides)
    local alias, name = ref:match("^([%w_]+)%.([%w_]+)$")
    if not alias then return nil end

    if namespace_overrides[alias] and namespace_overrides[alias][name] then
        return namespace_overrides[alias][name]
    end
    if namespaces[alias] then
        return namespaces[alias][name]
    end
    return nil
end

local function resolve_extends_target(ref, id_map, namespaces, namespace_overrides)
    if ref:sub(1, 1) == "#" then
        return id_map[ref:sub(2)]
    end
    return resolve_namespace_ref(ref, namespaces, namespace_overrides)
end

local function resolve_tree(node, stack, id_map, namespaces, namespace_overrides)
    table.insert(stack, node)

    for k, v in pairs(node) do
        if type(k) == "string" and k:sub(1, 1) ~= "_" then
            if type(v) == "string" then
                node[k] = resolve_refs(v, stack, id_map, namespaces, namespace_overrides)
            elseif type(v) == "table" and v.__unresolved_ref then
                local target = id_map[v.__unresolved_ref.id]
                local refkey = v.__unresolved_ref.key
                if target and target[refkey] ~= nil then
                    node[k] = target[refkey]
                else
                    node[k] = string.format("{unresolved:#%s.%s}", v.__unresolved_ref.id, refkey)
                end
            elseif type(v) == "table" and v.__unresolved_ns_ref then
                local ref = v.__unresolved_ns_ref
                local target = resolve_namespace_ref(ref.alias .. "." .. ref.type, namespaces, namespace_overrides)
                if target and target[ref.key] ~= nil then
                    node[k] = target[ref.key]
                else
                    node[k] = string.format("{unresolved:%s.%s.%s}", ref.alias, ref.type, ref.key)
                end
            elseif type(v) == "table" and v.__lua_expr then
                --Raw Lua source
            elseif type(v) == "table" and v._type then
                --Nested block stored as a property value
                resolve_tree(v, stack, id_map, namespaces, namespace_overrides)
            elseif type(v) == "table" then
                --Plain array from parse_array
                for idx, item in ipairs(v) do
                    if type(item) == "string" then
                        v[idx] = resolve_refs(item, stack, id_map, namespaces, namespace_overrides)
                    end
                end
            end
        end
    end

    for _, child in ipairs(node) do
        if type(child) == "table" then
            resolve_tree(child, stack, id_map, namespaces, namespace_overrides)
        end
    end

    table.remove(stack)
end

function parser.parse_string(content, current_path, import_cache)
    current_path = current_path or "."
    import_cache = import_cache or {}

    local root = {}
    local stack = { root }
    local id_map = {}
    local id_lines = {}
    local namespaces = {}
    local namespace_overrides = {}
    local current = root

    local lines = {}
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local i = 1
    while i <= #lines do
        local line = lines[i]:gsub("^%s*(.-)%s*$", "%1")
        line = strip_inline_comment(line)
        line = line:gsub("^%s*(.-)%s*$", "%1")

        if line ~= "" then
            -------------------
            --- @import <path> [as Alias]

            local import_target, import_alias =
                line:match("^@import%s*<([^>]+)>%s*as%s+([%w_]+)%s*$")
            if not import_target then
                import_target = line:match("^@import%s*<([^>]+)>%s*$")
            end

            if import_target then
                local default_alias = import_target:match("([%w_]+)$")
                local alias = import_alias or default_alias
                local import_path = normalize_path(dirname(current_path) .. "/" .. import_target) .. ".cdf"

                if import_cache[import_path .. ":loading"] then
                    error(string.format("[CDF] Circular @import of '%s' on line %d", import_path, i))
                end

                if not import_cache[import_path] then
                    import_cache[import_path .. ":loading"] = true
                    local imported_root, err = parser.parse_file(import_path, import_cache)
                    import_cache[import_path .. ":loading"] = nil
                    if err then
                        error(string.format("[CDF] @import failed for '%s' on line %d: %s", import_path, i, err))
                    end
                    import_cache[import_path] = imported_root
                end

                local ns = {}
                for _, node in ipairs(import_cache[import_path]) do
                    if type(node) == "table" and node._type then
                        ns[node._type] = node
                    end
                end
                namespaces[alias] = ns

            -------------------
            --- Block open "... (" (functions, plain blocks, prop-value blocks)

            elseif line:sub(-1) == "(" then
                local header_text = line:sub(1, -2):gsub("%s+$", "")

                local func_name, func_args_str = header_text:match("^function%s+([%w_]+)%s*%(([^)]*)%)$")
                if func_name then
                    --Function bodies are not parsed.
                    local args = {}
                    for a in func_args_str:gmatch("[^,%s]+") do
                        table.insert(args, a)
                    end

                    local raw_body = {}
                    i = i + 1
                    while i <= #lines do
                        local body_line = lines[i]:gsub("^%s*(.-)%s*$", "%1")
                        body_line = strip_inline_comment(body_line):gsub("%s*$", "")
                        if body_line == ")" then
                            break
                        end
                        if body_line ~= "" then
                            table.insert(raw_body, body_line)
                        end
                        i = i + 1
                    end

                    local new_obj = { _type = "function", _name = func_name, _args = args, _raw_body = raw_body }
                    table.insert(current, new_obj)
                    --Don't push in stack, since there's nothing to resolve or get from cdf data.
                else
                    local prop_key, rest = header_text:match("^([%l_][%w_.]*)%s*:%s*(.+)$")
                    local block_header_text = prop_key and rest or header_text
                    local header = parse_block_header(block_header_text)

                    if not header or not header.type:match("^%u") then
                        error(string.format("[CDF] Malformed block header on line %d: '%s'", i, line))
                    end

                    local ns, simple_type = header.type:match("^([%w_]+)%.([%w_]+)$")
                    local resolved_type = simple_type or header.type
                    local is_shadow = (not prop_key) and (not header.name) and ns and (not header.extends_ref) and (current == root)

                    local new_obj
                    if is_shadow then
                        new_obj = { _type = resolved_type, _shadow_ns = ns, _shadow_type = simple_type }
                    else
                        new_obj = { _type = resolved_type, _name = header.name }
                        if header.extends_ref then
                            new_obj.extends = header.extends_ref
                        elseif ns and not header.name then
                            new_obj.extends = header.type
                        end
                        if prop_key then
                            current[prop_key] = new_obj
                        else
                            table.insert(current, new_obj)
                        end

                        if header.name then
                            if id_map[header.name] then
                                error(string.format(
                                    "[CDF] Duplicate id '%s' on line %d (first defined on line %d)",
                                    header.name, i, id_lines[header.name]))
                            end
                            id_map[header.name] = new_obj
                            id_lines[header.name] = i
                        end
                    end

                    table.insert(stack, new_obj)
                    current = new_obj
                end

            -------------------
            --- Block close: ")"

            elseif line == ")" then
                if #stack > 1 then
                    local closing = current
                    table.remove(stack)
                    current = stack[#stack]

                    if closing._shadow_ns then
                        local base = resolve_namespace_ref(
                            closing._shadow_ns .. "." .. closing._shadow_type,
                            namespaces, namespace_overrides
                        )
                        local merged = { _type = closing._shadow_type }
                        if base then
                            for k, v in pairs(base) do
                                if type(k) == "string" and k:sub(1, 1) ~= "_" then
                                    merged[k] = v
                                end
                            end
                        end
                        for k, v in pairs(closing) do
                            if type(k) == "string" and k:sub(1, 1) ~= "_" then
                                merged[k] = v
                            end
                        end

                        namespace_overrides[closing._shadow_ns] = namespace_overrides[closing._shadow_ns] or {}
                        namespace_overrides[closing._shadow_ns][closing._shadow_type] = merged
                    elseif closing.extends then
                        local target = resolve_extends_target(closing.extends, id_map, namespaces, namespace_overrides)
                        if not target then
                            error(string.format("[CDF] extends target '%s' not found on line %d",
                                tostring(closing.extends), i))
                        end
                        for k, v in pairs(target) do
                            if type(k) == "string" and k:sub(1, 1) ~= "_"
                                and k ~= "extends" and closing[k] == nil then
                                closing[k] = v
                            end
                        end
                    end
                else
                    error(string.format("[CDF] Unexpected ')' on line %d", i))
                end

            -------------------
            --- Property: key: value

            else
                local key, value = line:match("^([%a_][%w_.]*)%s*:%s*(.*)$")
                if key then
                    local id_ref_target, id_ref_key = value:match("^#([%w_]+)%.([%w_]+)$")
                    local ns_ref_alias, ns_ref_type, ns_ref_key = value:match("^([%w_]+)%.([%w_]+)%.([%w_]+)$")
                    if id_ref_target then
                        current[key] = { __unresolved_ref = { id = id_ref_target, key = id_ref_key } }
                    elseif ns_ref_alias then
                        current[key] = { __unresolved_ns_ref = { alias = ns_ref_alias, type = ns_ref_type, key = ns_ref_key } }
                    elseif value:match("^%s*%[.*%]%s*$") then
                        current[key] = parse_array(value)
                    elseif value:match("^%s*\"\"\"") then
                        local multiline = {}
                        i = i + 1
                        while i <= #lines do
                            local m_line = lines[i]
                            if m_line:match("\"\"\"") then break end
                            m_line = m_line:gsub("^%s*", "")
                            table.insert(multiline, m_line)
                            i = i + 1
                        end
                        current[key] = table.concat(multiline, "\n")

                    else
                        current[key] = cast_value(value)
                    end
                else
                    error(string.format("[CDF] Malformed property on line %d: '%s'", i, lines[i]))
                end
            end
        end
        i = i + 1
    end

    if #stack > 1 then
        local deepest_block = stack[#stack]._type or "Unknown"
        error(string.format("[CDF] Closed file before finishing the '%s' block.", deepest_block))
    end

    resolve_tree(root, {}, id_map, namespaces, namespace_overrides)

    return root
end

--#endregion

function parser.parse_file(file_path, import_cache)
    local file = io.open(file_path, "r")
    if not file then return nil, "File not found: " .. file_path end
    local content = file:read("*a")
    file:close()
    return parser.parse_string(content, file_path, import_cache)
end

return parser