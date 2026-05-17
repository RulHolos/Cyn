---@class debug_data Only used for debugging data. Is a global table.
debug_data = {
	frame_groups = {},
	frame_world = 0xFFFF,
	render_layers = {},
}

lume = require("core.global_scripts.lume")

-------------------------------- Strings
---@param str string
---@return string
local function json_pretty(str)
	local ret = ''
	local indent = '	'
	local level = 0
	local in_string = false
	for i = 1, #str do
		local s = string.sub(str, i, i)
		if s == '{' and (not in_string) then
			level = level + 1
			ret = ret .. '{\n' .. string.rep(indent, level)
		elseif s == '}' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s}', ret, string.rep(indent, level))
		elseif s == '"' then
			in_string = not in_string
			ret = ret .. '"'
		elseif s == ':' and (not in_string) then
			ret = ret .. ': '
		elseif s == ',' and (not in_string) then
			ret = ret .. ',\n'
			ret = ret .. string.rep(indent, level)
		elseif s == '[' and (not in_string) then
			level = level + 1
			ret = ret .. '[\n' .. string.rep(indent, level)
		elseif s == ']' and (not in_string) then
			level = level - 1
			ret = string.format(
				'%s\n%s]', ret, string.rep(indent, level))
		else
			ret = ret .. s
		end
	end
	return ret
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

---@class json
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
---@return C
function json.deserialize(str)
	return cjson.decode(str)
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

-------------------------------- Math

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