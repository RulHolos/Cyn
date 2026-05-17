--- Helpers

---Remove dead entries from group list.
---@param g core.signals.group
local function _sweep(g)
    local list, j = g.list, 0
    for i = 1, #list do
        local e = list[i]
        if not e.dead then
            j = j + 1
            list[j] = e
        else
            e._g = nil
        end
    end
    for i = j + 1, #list do
        list[i] = nil
    end
    g.dirty = false
end

---Inserts entry into a sorted group (higher order = higher priority)
---@param list table
---@param entry table
local function _sortedInsert(list, entry)
    local n = #list
    if n == 0 or entry.order <= list[n].order then
        list[n + 1] = entry
        return
    end
    for i = 1, n do
        if list[i].order < entry.order then
            table.insert(list, i, entry)
            return
        end
    end
    list[n + 1] = entry
end

---Builds callback wrapper to a weak-owner if needed.
---@param callback function
---@param owner table?
---@return function, table?
local function _wrapCallback(callback, owner)
    if not owner then
        return callback, nil --Emballé c'est plié
    end
    local weak = setmetatable({ owner }, { __mode = "v" })
    local entryBox = {} -- wrapper ref
    local function wrapped(...)
        if weak[1] then
            callback(...)
        else
            local e = entryBox[1]
            if e and not e.dead then
                e.dead = true
                local g = e._g
                if g then
                    g.dirty = true
                    entryBox[1] = nil
                end
            end
        end
    end
    return wrapped, entryBox
end

--- Signals system
--- Based on handles and zero-alloc on emition to avoid gc pressure

---Handles are the way to disconnect a signal. Store it in your objects.
---When the owner object is destroyed, call handle:disconnect or you will leak.
---@class core.signals.handle
local Handle = {}
Handle.__index = Handle

function Handle:Disconnect()
    local e = self._e
    if not e then return end
    if not e.dead then
        e.dead = true
        local g = e._g
        if g then
            g.dirty = true
            if g.depth == 0 then
                _sweep(g)
            end
        end
    end
    self._e = nil
end

function Handle:IsConnected()
    return self._e ~= nil and not self._e.dead
end

function Handle:SetEnabled(enabled)
    if self._e then
        self._e.enabled = enabled
    end
end

function Handle:IsEnabled()
    return self._e ~= nil and not self._e.dead and self._e.enabled
end

---@class core.signals.group
---@field list table[] Entries sorted by order
---@field dirty boolean Need to sweep dead entries
---@field depth integer >0 = currently emitting

---@class core.signals
local M = {
    _groups = {},
    _individual = {},
}

---Creates a signal instance.
---@return core.signals
function M.new()
    return makeInstance(M)
end

---Registers a callback.
---
---Returns an handle, store it on the object owner and call handle:disconnect()
---when the object is destroyed to avoid leaks.
---@param name string Identifier for Unregister
---@param group string? Signal group. nil is individual signal.
---@param callback function
---@param order number? Higher order = higher priority. Default is 0.
---@param owner table? Weak-owner. Auto-disconnects when owner get GC'd
---@return core.signals.handle
function M:Register(name, group, callback, order, owner)
    local cb, entryBox = _wrapCallback(callback, owner)

    ---@class core.signals.entry
    local entry = {
        name = name,
        cb = cb,
        order = order or 0,
        dead = false,
        enabled = true,
        _g = nil, --back-ref of group
    }

    if entryBox then
        entryBox[1] = entry
    end

    if group and group ~= "" then
        local g = self._groups[group]
        if not g then
            g = {
                list = {},
                dirty = false,
                depth = 0,
                enabled = true,
            }
            self._groups[group] = g
        end
        entry._g = g
        _sortedInsert(g.list, entry)
    else
        self._individual[name] = entry
    end

    return setmetatable({ _e = entry }, Handle)
end

---Emits a signal.
---
---Individual signals are priority over groups.
---@param signal string
---@param ... unknown
function M:Emit(signal, ...)
    local ind = self._individual[signal]
    if ind then
        if not ind.dead and ind.enabled then
            ind.cb(...)
        end
    end

    local g = self._groups[signal]
    if not g or not g.enabled then
        return
    end

    g.depth = g.depth + 1
    local list = g.list
    local n = #list
    for i = 1, n do
        local e = list[i]
        if not e.dead and e.enabled then
            e.cb(...)
        end
    end
    g.depth = g.depth - 1

    if g.dirty and g.depth == 0 then
        _sweep(g)
    end
end

---One-shot emit.
---
---Closure is allocated once.
---@param name string
---@param group string?
---@param callback function
---@param order number?
function M:Once(name, group, callback, order)
    local handle
    handle = self:Register(name, group, function(...)
        handle:Disconnect()
        handle = nil
        callback(...)
    end, order)
    return handle
end

---Returns a handle for an existing registered signal by name.
---@param name string
---@param group string?
---@return core.signals.handle?
function M:Get(name, group)
    local entry
    if group and group ~= "" then
        local g = self._groups[group]
        if not g then return nil end
        for i = 1, #g.list do
            local e = g.list[i]
            if e.name == name and not e.dead then
                entry = e
                break
            end
        end
    else
        local e = self._individual[name]
        if e and not e.dead then
            entry = e
        end
    end
    if not entry then return nil end
    return setmetatable({ _e = entry }, Handle)
end

---Unregisters by name. Slower than disconnecting handles.
---@param name string
---@param group string?
function M:Unregister(name, group)
    if group and group ~= "" then
        local g = self._groups[group]
        if not g then return end
        for i = 1, #g.list do
            local e = g.list[i]
            if e.name == name and not e.dead then
                e.dead  = true
                g.dirty = true
                if g.depth == 0 then _sweep(g) end
                return
            end
        end
    else
        local e = self._individual[name]
        if e then
            e.dead = true
            self._individual[name] = nil
        end
    end
end

---Removes every handles registered.
---@param signal string
function M:Clear(signal)
    self._individual[signal] = nil

    local g = self._groups[signal]
    if not g then return end

    if g.depth > 0 then
        -- If emitting, deferred clear.
        for i = 1, #g.list do
            local e = g.list[i]
            e.dead = true
            e._g = nil
        end
        g.dirty = true
    else
        for i = 1, #g.list do
            g.list[i]._g = nil
        end
        self._groups[signal] = nil
    end
end

---Sets the enabled state of a signal.
---@param name string
---@param group string?
---@param enabled boolean
function M:SetEnabled(name, group, enabled)
    if group and group ~= "" then
        local g = self._groups[group]
        if not g then
            return
        end
        for i = 1, #g.list do
            if g.list[i].name == name then
                g.list[i].enabled = enabled
                return
            end
        end
    else
        local e = self._individual[name]
        if e then
            e.enabled = enabled
        end
    end
end

---Enable/disable an entire group at once.
---@param group string
---@param enabled boolean
function M:SetGroupEnabled(group, enabled)
    local g = self._groups[group]
    if g then g.enabled = enabled end
end

core.signals = M.new()

return M