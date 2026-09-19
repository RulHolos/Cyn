local imgui_exists, imgui = pcall(require, "imgui")

local ImGui = imgui.ImGui
local ImVec2 = imgui.ImVec2
local ImKey = imgui.ImGuiKey
local ImWindowFlags = imgui.ImGuiWindowFlags
local ImInputTextFlags = imgui.ImGuiInputTextFlags
local ImTextBuffer = imgui.ImGuiTextBuffer
local ImStyleVar = imgui.ImGuiStyleVar

---@class lstg.debug.view.Player : lstg.debug.view
local Player = {}

function Player:getWindowName() return "Player Debugger" end
function Player:getMenuGroup() return "Tools" end
function Player:getViewId() return "view.Player" end
function Player:getEnabled() return self.enabled end
---@param v boolean
function Player:setState(v) self.enabled = v end

function Player:frame() end
function Player:layout()
    local player = cyn.player.instance
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

    _, player.in_dialog = ImGui.Checkbox("In dialog?", player.in_dialog)

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

return Player
