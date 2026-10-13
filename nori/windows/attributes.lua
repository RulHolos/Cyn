local imgui = require("imgui")
local ImGui = imgui.ImGui

---@class nori.window.attributes : nori.window
local attributes = {}

function attributes:init()
    self.name = "attributes"

    ---@type imgui.ImGuiWindowFlags
    self.flags = imgui.ImGuiWindowFlags.None

    self.is_open = true
end

function attributes:render()
    local w_ok, is_open = ImGui.Begin("Attributes##NoriAttributes", self.is_open, self.flags)
    if w_ok then
        self:menu()

        --TODO
    end
    self.is_open = is_open
    ImGui.End()
end

function attributes:menu()
end

return attributes