---@diagnostic disable: duplicate-set-field wtf this makes no sense

local yeva_player = require("yeva.player")

local imgui_exists, imgui = pcall(require, "imgui")
local ImGui = imgui.ImGui

---@class yeva.debug.view.player : cyn.debug.view
local M = {}

function M:getWindowName() return "Player Debugger" end
function M:getMenuGroup() return "Tools" end
function M:getViewId() return "view.Player" end
function M:getEnabled() return self.enabled end
---@param v boolean
function M:setState(v) self.enabled = v end

function M:frame() end
function M:layout()
    local player = yeva_player.instance
    if player == nil then
        ImGui.Text("No player instance found.")
        return
    end

    ImGui.Text("Player Debugger for " .. player.name .. " (" .. player.full_name .. ")")
    ImGui.Text(("Position: x=%s, y=%s"):format(player.x, player.y))

    local success, value = ImGui.InputInt("Protect Time", player.protect, 1, 15)
    if success then
        player.protect = math.clamp(value, 0, 1000000)
    end

    _, player.in_dialog = ImGui.Checkbox("In Dialog?", player.in_dialog)

    ImGui.Separator()

    if ImGui.CollapsingHeader("Behavior Debuggers") then
        for k, v in pairs(player.behaviors) do
            ImGui.PushID(k)

            ImGui.SeparatorText(k)
            if v.debug then
                v:debug()
            else
                ImGui.Text("No debugger for this behavior.")
            end

            ImGui.PopID()
        end
    end
end

return M