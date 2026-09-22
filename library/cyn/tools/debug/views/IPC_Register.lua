local imgui_exists, imgui = pcall(require, "imgui")

local ImGui = imgui.ImGui
local ImVec2 = imgui.ImVec2
local ImKey = imgui.ImGuiKey
local ImWindowFlags = imgui.ImGuiWindowFlags
local ImInputTextFlags = imgui.ImGuiInputTextFlags
local ImTextBuffer = imgui.ImGuiTextBuffer
local ImStyleVar = imgui.ImGuiStyleVar

---@class cyn.debug.view.IPC_Register : cyn.debug.view
local IPC_Register = {}

function IPC_Register:getWindowName() return "IPC Register" end
function IPC_Register:getMenuGroup() return "Tools" end
function IPC_Register:getViewId() return "view.IPC_Register" end
function IPC_Register:getEnabled() return self.enabled end
---@param v boolean
function IPC_Register:setState(v) self.enabled = v end

function IPC_Register:frame() end
function IPC_Register:layout()
    ImGui.Text("Here is a list of all the registered IPC commands:")

    local functions = debug.getregistry()["lstg.IPC.functions"]
    if functions then
        for name, fn in pairs(functions) do
            ImGui.Text("- " .. name)
        end
    end
end

return IPC_Register
