---@class core.global.debug_data Only used for debugging data. Is a global table.
debug_data = {
	frame_groups = {},
	frame_world = 0xFFFF,
	render_layers = {},
}

lume = require("core.global_scripts.lume")
toml = require("core.global_scripts.toml")

-------------------------------- Strings

---Prettifies a raw or minified JSON string.
---@param str string Raw or minified JSON string.
---@return string Prettified JSON string.
local function json_pretty(str)
    local ret = {}
    local indent = '    '
    local level = 0
    local in_string = false
    local escaped = false

    for i = 1, #str do
        local char = str:sub(i, i)

        if in_string then
            ret[#ret + 1] = char
            if char == '"' and not escaped then
                in_string = false
            end
            escaped = (char == '\\' and not escaped)
        else
            if not char:find('%s') then
                if char == '{' or char == '[' then
                    level = level + 1
                    ret[#ret + 1] = char .. '\n' .. indent:rep(level)
                elseif char == '}' or char == ']' then
                    level = level - 1
                    ret[#ret + 1] = '\n' .. indent:rep(level) .. char
                elseif char == ',' then
                    ret[#ret + 1] = ',\n' .. indent:rep(level)
                elseif char == ':' then
                    ret[#ret + 1] = ': '
                elseif char == '"' then
                    in_string = true
                    ret[#ret + 1] = char
                else
                    ret[#ret + 1] = char
                end
            end
        end
    end

    return table.concat(ret)
end

string.json_pretty = json_pretty

string.split = function(str, delimiter)
	local result = {}
	for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

-------------------------------- Json

---@class core.global.json
json = {}

local cjson = require("cjson")

local function visit_table(t)
	local ret = {}
	if getmetatable(t) and getmetatable(t).data then
		t = getmetatable(t).data
	end
	for k, v in pairs(t) do
		if type(v) == "table" then
			ret[k] = visit_table(v)
		else
			ret[k] = v
		end
	end
	return ret
end

---Visits a table and serializes it to json.
---@return string @Serialized table in string format
function json.serialize(t)
	if type(t) == "table" then
		t = visit_table(t)
	end
	return cjson.encode(t)
end

---Transforms a serialized string into a table, ignores functions.
---@param str string Serialized json
---@generic C
---@param optional boolean? If true, will no-op if the file cannot be found.
---@return C
function json.deserialize(str, optional)
	if optional then
		local ok, result = pcall(cjson.decode, str)
		if not ok then
			lstg.Log(LOG.ERROR, "Failed to deserialize JSON string at path: " .. tostring(str))
			return nil
		end
		return result
	else
		return cjson.decode(str)
	end
end

-------------------------------- Tables

---@generic T
---@generic V
---@param t T
---@param v V
table.has_ivalue = function(t, v)
	for _, val in ipairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

---@generic T
---@generic V
---@param t T
---@param v V
table.has_ikey = function(t, v)
	for key, _ in ipairs(t) do
		if key == v then
			return true
		end
	end
	return false
end

---@generic T
---@generic V
---@param t T
---@param v V
table.has_value = function(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

---@generic T
---@generic V
---@param t T
---@param v V
table.has_key = function(t, v)
	for key, _ in pairs(t) do
		if key == v then
			return true
		end
	end
	return false
end

---Apply a function to each value in the given array that satisfies a predicate.
---@param tbl table
---@param predicate fun(v:any, i:integer):boolean
---@param action fun(v:any, i:integer)
table.foreach_ipairs = function(tbl, predicate, action)
	for i, v in ipairs(tbl) do
		if predicate(v, i) then
			action(v, i)
		end
	end
end

---Apply a function to each value in the given table that satisfies a predicate.
---@param tbl table
---@param predicate fun(v:any, k:any):boolean
---@param action fun(v:any, k:any)
table.foreach_pairs = function(tbl, predicate, action)
	for k, v in pairs(tbl) do
		if predicate(v, k) then
			action(v, k)
		end
	end
end

---Recursively prints a table, with key sorting and infinite recursion prevention.
---@param t table Table to print
---@param idt integer|nil Identation
---@param seen table|nil Subtable visit tracker
table.print = function(t, idt, seen)
	local idt = idt or 0
	local idtStr = string.rep("  ⤷ ", idt)

	local seen = seen or {}
	seen[t] = true

	local keys = {}
	for k in pairs(t) do
		keys[#keys + 1] = k
	end

	table.sort(keys, function(a, b)
		if type(a) == "number" and type(b) == "number" then
			return a < b
		end
		return tostring(a) < tostring(b)
	end)

	for i = 1, #keys do
        local key = keys[i]
        local val = t[key]

        if type(key) == "string" then
            key = idtStr .. "[\"" .. key .. "\"]"
        else
            key = idtStr .. "[" .. tostring(key) .. "]"
        end

        if type(val) == "table" and not seen[val] then
            seen[val] = true
            lstg.Log(LOG.DEBUG, key .. ":")
            table.print(val, idt + 1, seen)
            seen[val] = nil

        else
            lstg.Log(LOG.DEBUG, key .. " = " .. tostring(val))
        end
    end
end

-------------------------------- Math

math.PIx2 = math.pi * 2
math.PI_2 = math.pi * 0.5
math.PI_4 = math.pi * 0.25
math.SQRT2 = math.sqrt(2)
math.SQRT3 = math.sqrt(3)
math.SQRT2_2 = math.sqrt(0.5)
math.GOLD = 360 * (math.sqrt(5) - 1) / 2

sin = lstg.sin
cos = lstg.cos
tan = lstg.tan
asin = lstg.asin
acos = lstg.acos
atan = lstg.atan
atan2 = lstg.atan2

if not math.mod then
	math.mod = function(a, b)
		return a % b
	end
end

function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

function math.hypot(x, y)
	return math.sqrt(x * x + y * y)
end

function math.clamp(v, v_min, v_max)
	return math.max(v_min, math.min(v_max, v))
end

function math.wrap(value, min, max)
	local range = max - min + 1
	return ((value - min) % range + range) % range + min
end

-------------------------------- Log

---@class core.global.LOG
LOG = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5,
}

function lstg.MsgBoxWarn(msg)
	local ret = lstg.MessageBox("Warning", tostring(msg), 49)
	if ret == 2 then
		core.quit_flag = true
	end
end

function lstg.MsgBoxError(msg, title, exit)
	local ret = lstg.MessageBox(title, tostring(msg), 16)
	if ret == 1 and exit then
		core.quit_flag = true
	end
end