--#region Main Dialog class

---The dialog system of Cyn can trigger dialogs anywhere in the game.
---It is designed to integrate seamlessly with the CTF/i18n system.
---You don't define dialogs in lua, nor lines, everything, including characters data, music and dialog actions (like showing the boss's name) is defined in the CTF file.
---@class core.misc.dialog : core.object
local M = core.object.define()

---@class core.misc.dialog.config
local global_dialog_config = {
    ---@type "box"|"bubble" The dialog style. "bubble" is speech like most recent touhou games, "box" is the old-school way of showing dialogs.
    style = "box",
    ---@type integer The number of frame it takes for portraits to go back and forth
    portrait_move_frame = 10,
    ---@type integer The maximum number of frames to wait before automatically progressing through a dialog.
    max_wait_frame = 60 * 60 * 5, --5 minutes,
    ---@type boolean Whether to automatically progress through a dialog after max_wait_frame
    automatically_progress = true,
}
local gdc = global_dialog_config

function M:init()
    self.layer = core.object.layer.TOP + 50
    self.group = core.object.group.GHOST

    self.style = gdc.style
    self.portrait_move_frame = gdc.portrait_move_frame
end

function M:frame()
end

function M:render()
end

--#endregion

return M