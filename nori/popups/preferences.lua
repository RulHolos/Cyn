local imgui_ext = require("nori.imgui_ext")
local imgui = require("imgui")
local ImGui = imgui.ImGui
local ImVec2 = imgui.ImVec2
local bor = bit.bor

---@class nori.window.preferences : nori.window
local preferences = {}

function preferences:init()
    self.name = "preferences"

    ---@type imgui.ImGuiWindowFlags
    self.flags = imgui.ImGuiWindowFlags.NoDocking

    self.is_open = false
    self.open_popup_cmd = false

    self.nav_tabs = { "General", "Interface", "Shortcuts", "Compilation" }
    self.selected_nav_tab = 1
end

function preferences:render()
    local just_opened = false

    if self.open_popup_cmd then
        just_opened = true
        self.open_popup_cmd = false
        self.is_open = true

        imgui_ext.CenterNextWindow(imgui.ImGuiCond.Appearing)
        ImGui.SetNextWindowSize(ImVec2(ImGui.GetTextLineHeight() * 50, ImGui.GetTextLineHeight() * 30), imgui.ImGuiCond.FirstUseEver)
    end

    if self.is_open then
        local lastNavTab = self.selected_nav_tab

        local w_ok, is_open = ImGui.Begin("Preferences##NoriPreferences", self.is_open, self.flags)
        if w_ok then
            ImGui.BeginChild("Nav", ImVec2(ImGui.GetTextLineHeight() * 12, ImGui.GetContentRegionAvail().y), imgui.ImGuiChildFlags.Borders)
            for i = 1, #self.nav_tabs do
                if ImGui.Selectable(self.nav_tabs[i], i == self.selected_nav_tab) then
                    self.selected_nav_tab = i
                end
            end
            ImGui.EndChild()

            ImGui.SameLine()
            ImGui.BeginChild("Controls", ImGui.GetContentRegionAvail())
            do
                if self.selected_nav_tab == 1 then
                    ImGui.Text("TODO: General")
                elseif self.selected_nav_tab == 2 then
                    ImGui.Text("TODO: Interface")
                elseif self.selected_nav_tab == 3 then
                    ImGui.Text("TODO: Shortcuts")
                elseif self.selected_nav_tab == 4 then
                    ImGui.Text("TODO: Compilation")
                end
            end
            ImGui.EndChild()
        end
        ImGui.End()
        self.is_open = is_open

        if not self.is_open then
            --TODO
        end
    else
        --TODO
    end
end

function preferences:menu()
end

return preferences