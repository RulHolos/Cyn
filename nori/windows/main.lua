local cdf = require("cyn.presentation.cdf")
local imgui = require("imgui")
local ImGui = imgui.ImGui
local bor = bit.bor

---@type nori.file
local empty_file_template = {
    path = "test",
    data = {
        _type = "NoriFile", --nf
        _name = "TestFile",
        _order = { "RootNode" },

        RootNode = "TempValueForNonExistingNodeRunaChangeThisPlease"
    },
}

---@class nori.window.main : nori.window
local main = {}

function main:init()
    self.name = "main"

    ---@type imgui.ImGuiWindowFlags
    self.flags = imgui.ImGuiWindowFlags.MenuBar

    self.is_open = true

    ---@type nori.file
    self.file = nil
end

function main:render()
    local w_ok, is_open = ImGui.Begin("View##NoriView", self.is_open, self.flags)
    if w_ok then
        self:menu()

        self:display_file()
    end
    self.is_open = is_open
    ImGui.End()
end

function main:menu()
    if (ImGui.BeginMenuBar()) then
        if (ImGui.BeginMenu("File")) then
            if (ImGui.MenuItem("New", "Ctrl+N")) then
                table.insert(self.parent.open_files, MakeInstance(empty_file_template))
                self.parent.selected_file_index = #self.parent.open_files
                self.file = self.parent.open_files[self.parent.selected_file_index]
            end
            ImGui.MenuItem("Open", "Ctrl+O")
            if (ImGui.MenuItem("Save", "Ctrl+S", nil, self.file ~= nil and self.file.path ~= "")) then
                print("Saving file...")
                local ok, err = cdf.writer.write_file("example_nf_file", empty_file_template.data)
                if not ok then
                    print("Error saving file:", err)
                end
            end
            ImGui.MenuItem("Save As...", "Ctrl+Shift+S", nil, self.file ~= nil)

            ImGui.Separator()

            local preference_window = self.parent:find_window_by_name("preferences") --[[@as nori.window.preferences]]
            if ImGui.MenuItem("Preferences", nil, preference_window.is_open) then
                preference_window.open_popup_cmd = true
            end

            ImGui.EndMenu()
        end
        if (ImGui.BeginMenu("Edit")) then
            ImGui.EndMenu()
        end
        ImGui.EndMenuBar()
    end
end

function main:display_file()
    if ImGui.BeginTabBar("NoriFileTabs", bor(imgui.ImGuiTabBarFlags.AutoSelectNewTabs, imgui.ImGuiTabBarFlags.NoCloseWithMiddleMouseButton)) then
        for i, file in ipairs(self.parent.open_files) do
            ImGui.PushID("FileTab" .. i)
            local tab_open = ImGui.BeginTabItem(file.path)
            if tab_open then
                self:render_treeview(file)
                ImGui.EndTabItem()
            end
            ImGui.PopID()
        end
        ImGui.EndTabBar()
    end
end

--#region TreeView

---@param file nori.file
function main:render_treeview(file)
end

function main:render_context_menu()
    if ImGui.BeginPopupContextItem("{node.Hash}_context") then
        if ImGui.MenuItem("Edit", "Ctrl+E", false, true) then
        end

        ImGui.Separator()

        if ImGui.MenuItem("Undo", "Ctrl+Z", false, true) then
        end
        if ImGui.MenuItem("Redo", "Ctrl+Y", false, true) then
        end

        ImGui.Separator()

        if ImGui.MenuItem("Cut", "Ctrl+X", false, true) then
        end
        if ImGui.MenuItem("Copy", "Ctrl+C", false, true) then
        end
        if ImGui.MenuItem("Paste", "Ctrl+V", false, true) then
        end

        ImGui.Separator()

        if ImGui.MenuItem("Delete", "Del", false, true) then
        end

        ImGui.Separator()

        if ImGui.MenuItem("Ban", "", false, true) then
        end

        ImGui.Separator()

        if ImGui.MenuItem("View Code", "F12", false, true) then
        end
        if ImGui.MenuItem("Save as Preset", "", false, true) then
        end

        ImGui.EndPopup()
    end
end

--#endregion

return main