local imgui = require("imgui")
local ImGui = imgui.ImGui
local ImVec2 = imgui.ImVec2

---@class nori.imgui_ext
local M = {}

---TODO
---@param cond imgui.ImGuiCond
function M.CenterNextWindow(cond)
    local viewport = ImGui.GetMainViewport()
    ImGui.SetNextWindowPos(viewport:GetCenter(), cond, ImVec2(0.5, 0.5))
end

---Ensures that the popup is open
---@param id string The ID of the popup to open
---@return boolean True if the popup was opened, false if it was already open
function M.EnsurePopupIsOpen(id)
    if not ImGui.IsPopupOpen(id) then
        ImGui.OpenPopup(id)
        return true
    end
    return false
end

return M