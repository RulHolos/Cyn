---@class cyn.IUserdata
---@field create_directories fun() Creates necessary directories for the userdata system.
---@field get_root_directory fun():string
---@field get_snapshot_directory fun():string
---@field get_replay_directory fun():string
---@field get_named_database fun():string Returns a different path based on the name of the currently running game.
---@field scoredata table Data containing player data informations. Not settings.

---Represents a proxy manager for userdata access.
---@class cyn.userdata_manager
local M = {
    ---@type cyn.IUserdata
    userdata = nil
}

---Sets the userdata instance.
---@generic T : cyn.IUserdata
---@param userdata_class T
function M:set_userdata_class(userdata_class)
    assert(userdata_class, "userdata_class must not be nil")
    self.userdata = userdata_class
end

---Shorthand for the userdata.scoredata table.
---@return cyn.IUserdata
function M:get()
    assert(self.userdata, "userdata instance is not set")
    return self.userdata.scoredata
end

return M