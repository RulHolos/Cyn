---Warning: VERY PROBABLY VERY PROKEN. PROCEED WITH CAUTION

---@class cyn.cdf.writer
local writer = {}

local INDENT_UNIT = "    "

--#region Value constructors

---Writes a raw Lua expression so it's unquoted.
---@param lua_expr_text string
function writer.raw(lua_expr_text)
    assert(type(lua_expr_text) == "string", "raw(text) expects a string")
    return { __cdf_raw = lua_expr_text }
end

---Same-file reference by block id: writes `#id.key`.
---@param id string
---@param key string
function writer.idref(id, key)
    assert(type(id) == "string" and type(key) == "string", "idref(id, key) expects two strings")
    return { __cdf_idref = { id = id, key = key } }
end

---Reference into an @ imported namespace: writes `alias.Type.key`
---@param alias string
---@param type_name string
---@param key string
function writer.nsref(alias, type_name, key)
    assert(type(alias) == "string" and type(type_name) == "string" and type(key) == "string",
        "nsref(alias, type, key) expects three strings")
    return { __cdf_nsref = { alias = alias, ["type"] = type_name, key = key } }
end

--#endregion

--#region Table shape helpers

local function is_sentinel(v)
    return type(v) == "table" and (v.__cdf_raw ~= nil or v.__cdf_idref ~= nil or v.__cdf_nsref ~= nil)
end

local function is_block_table(v)
    return type(v) == "table" and not is_sentinel(v) and type(v._type) == "string" and v._type ~= ""
end

local function array_length(t)
    local n = 0
    for k in pairs(t) do
        if type(k) ~= "number" or k ~= math.floor(k) or k < 1 then
            return nil
        end
        if k > n then n = k end
    end
    for i = 1, n do
        if t[i] == nil then return nil end
    end
    return n
end

local function is_plain_array(v)
    if type(v) ~= "table" or is_block_table(v) or is_sentinel(v) then return false end
    return array_length(v) ~= nil
end

--#endregion

--#region Validation

local TYPE_PATTERN = "^%u[%w_.]*$"
local WORD_PATTERN = "^[%w_]+$"
local PROP_KEY_PATTERN = "^[%a_][%w_.]*$"
local LOWER_PROP_KEY_PATTERN = "^[%l_][%w_.]*$"
local RAW_EXPR_PATTERN = "^[%a_][%w_.]*%s*%(.*%)$"

local function fail(fmt, ...)
    error(string.format(fmt, ...))
end

local function validate_type(t, where)
    if not t:match(TYPE_PATTERN) then
        fail("cdf.write: invalid _type %q at %s (must start with an uppercase letter)", t, where)
    end
end

local function validate_name(n, where)
    if n ~= nil and not n:match(WORD_PATTERN) then
        fail("cdf.write: invalid _name %q at %s (letters, digits, underscore only)", n, where)
    end
end

local function validate_prop_key(k, where, needs_lowercase)
    local pattern = needs_lowercase and LOWER_PROP_KEY_PATTERN or PROP_KEY_PATTERN

    if not k:match(pattern) then
        if needs_lowercase then
            fail(
                "cdf.write: property key %q at %s has a nested block, so it must start with a lowercase letter or underscore",
                k, where)
        else
            fail("cdf.write: invalid property key %q at %s", k, where)
        end
    end
end

--#endregion

--#region Scalar Serialization

---Safe to emit as a `"..."` string.
local function is_simple_string(s)
    return not s:find('"', 1, true) and not s:find("\n", 1, true)
end

local function serialize_scalar(v, where)
    local tv = type(v)
    if tv == "string" then
        if is_simple_string(v) then
            return '"' .. v .. '"'
        end
        fail("cdf.write: string value at %s contains a newline or a `\"` character; " ..
            "write it as a direct property value (not inside an array) so it can use \"\"\"...\"\"\" instead", where)
    elseif tv == "number" or tv == "boolean" then
        return tostring(v)
    elseif tv == "table" and v.__cdf_raw ~= nil then
        local expr = v.__cdf_raw
        if not expr:match(RAW_EXPR_PATTERN) then
            fail("cdf.write: raw() value %q at %s doesn't look like `name(args)` and would be " ..
                "re-read back as a plain string, not a Lua expression", expr, where)
        end
        return expr
    elseif tv == "table" and v.__cdf_idref ~= nil then
        local r = v.__cdf_idref
        if not r.id:match(WORD_PATTERN) or not r.key:match(WORD_PATTERN) then
            fail("cdf.write: idref(%q, %q) at %s has invalid characters", tostring(r.id), tostring(r.key), where)
        end
        return "#" .. r.id .. "." .. r.key
    elseif tv == "table" and v.__cdf_nsref ~= nil then
        local r = v.__cdf_nsref
        if not r.alias:match(WORD_PATTERN) or not r.type:match(WORD_PATTERN) or not r.key:match(WORD_PATTERN) then
            fail("cdf.write: nsref(%q, %q, %q) at %s has invalid characters", tostring(r.alias), tostring(r.type),
                tostring(r.key), where)
        end
        return r.alias .. "." .. r.type .. "." .. r.key
    end

    fail("cdf.write: value at %s is a %s, which cdf.write doesn't know how to serialize", where, tv)
end

local function serialize_array(arr, where)
    local parts = {}
    for idx, item in ipairs(arr) do
        if is_block_table(item) or is_plain_array(item) then
            fail("cdf.write: array at %s contains a nested block/array at index %d; " ..
                "CDF arrays can only hold strings, numbers, booleans and raw/idref/nsref values", where, idx)
        end
        parts[#parts + 1] = serialize_scalar(item, where .. "[" .. idx .. "]")
    end
    if #parts == 0 then
        return "[]"
    end
    return "[ " .. table.concat(parts, ", ") .. " ]"
end

--#endregion

--#region BLock serialization

local function ordered_keys(block, where)
    local seen = {}
    local order = {}

    if block._order ~= nil then
        if type(block._order) ~= "table" then
            fail("cdf.write: _order at %s must be an array of key names", where)
        end
        for _, k in ipairs(block._order) do
            if block[k] == nil then
                fail("cdf.write: _order at %s lists %q, but that key isn't set on the table", where, tostring(k))
            end
            order[#order + 1] = k
            seen[k] = true
        end
    end

    local rest = {}
    for k in pairs(block) do
        if type(k) == "string" and k:sub(1, 1) ~= "_" and not seen[k] then
            rest[#rest + 1] = k
        end
    end
    table.sort(rest)

    for _, k in ipairs(rest) do
        order[#order + 1] = k
    end

    return order
end

local write_block

local function write_property(buf, key, value, depth, where)
    local indent = INDENT_UNIT:rep(depth)
    local prop_where = where .. "." .. key

    if is_block_table(value) then
        validate_prop_key(key, prop_where, true)
        write_block(buf, value, depth, key, prop_where)
    elseif is_plain_array(value) then
        validate_prop_key(key, prop_where, false)
        buf[#buf + 1] = indent .. key .. ": " .. serialize_array(value, prop_where)
    elseif type(value) == "string" and not is_simple_string(value) then
        validate_prop_key(key, prop_where, false)
        buf[#buf + 1] = indent .. key .. ': """'
        for line in (value .. "\n"):gmatch("([^\n]*)\n") do
            if line:find('"""', 1, true) then
                fail('cdf.write: string value at %s contains a literal """, which would ' ..
                    "prematurely close the multiline block", prop_where)
            end
            buf[#buf + 1] = INDENT_UNIT:rep(depth + 1) .. line
        end
        buf[#buf + 1] = indent .. '"""'
    else
        validate_prop_key(key, prop_where, false)
        buf[#buf + 1] = indent .. key .. ": " .. serialize_scalar(value, prop_where)
    end
end

write_block = function(buf, block, depth, prop_key, where)
    where = where or ("<" .. tostring(block._type) .. ">")
    validate_type(block._type, where)
    validate_name(block._name, where)

    local indent = INDENT_UNIT:rep(depth)
    local header = block._type
    if block._name then
        header = header .. ":" .. block._name
    end
    if block._extends then
        if type(block._extends) ~= "string" or block._extends == "" then
            fail("cdf.write: _extends at %s must be a non-empty string", where)
        end
        header = header .. " | " .. block._extends
    end

    if prop_key then
        buf[#buf + 1] = indent .. prop_key .. ": " .. header .. " ("
    else
        buf[#buf + 1] = indent .. header .. " ("
    end

    local i = 1
    while block[i] ~= nil do
        local child = block[i]
        if not is_block_table(child) then
            fail("cdf.write: entry %d at %s must be a block table (with a _type field)", i, where)
        end
        write_block(buf, child, depth + 1, nil, where .. "[" .. i .. "]")
        i = i + 1
    end

    for _, key in ipairs(ordered_keys(block, where)) do
        write_property(buf, key, block[key], depth + 1, where)
    end

    buf[#buf + 1] = indent .. ")"
end

--#endregion

--#region Public API

function writer.write(blocks)
    assert(type(blocks) == "table", "cdf.write expects a table")

    local top_level
    if is_block_table(blocks) then
        top_level = { blocks }
    else
        if not array_length(blocks) then
            fail("cdf.write expects a block table (with _type) or a plain array of block tables")
        end
        top_level = blocks
    end

    local buf = {}
    for idx, block in ipairs(top_level) do
        if not is_block_table(block) then
            fail("cdf.write: top-level entry %d is not a block table (missing _type)", idx)
        end
        write_block(buf, block, 0, nil, "<root>[" .. idx .. "]")
        buf[#buf + 1] = ""
    end

    if #buf > 0 and buf[#buf] == "" then
        buf[#buf] = nil
    end

    return table.concat(buf, "\n") .. "\n"
end

---@param relative_path string
---@param blocks table
---@return boolean|nil ok
---@return string|nil err
function writer.write_file(relative_path, blocks)
    local ok, text_or_err = pcall(writer.write, blocks)
    if not ok then
        return nil, text_or_err
    end

    local path = relative_path .. ".cdf"
    local f, err = io.open(path, "w")
    if not f then
        return nil, err
    end

    f:write(text_or_err)
    f:close()

    return true
end

--#endregion

return writer
