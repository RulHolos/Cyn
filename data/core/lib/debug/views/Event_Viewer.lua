local imgui_exists, imgui = pcall(require, "imgui")

local ImGui = imgui.ImGui
local ImVec2 = imgui.ImVec2
local ImWindowFlags = imgui.ImGuiWindowFlags
local ImStyleVar = imgui.ImGuiStyleVar

---@class lstg.debug.Event_Viewer : lstg.debug.view
local Event_Viewer = {}

function Event_Viewer:getWindowName() return "Event Viewer" end
function Event_Viewer:getMenuGroup() return "Tools" end
function Event_Viewer:getViewId() return "view.Event_Viewer" end
function Event_Viewer:getEnabled() return self.enabled end
---@param v boolean
function Event_Viewer:setState(v) self.enabled = v end

function Event_Viewer:frame() end
function Event_Viewer:layout()
    if ImGui.BeginTabBar("EventViewerTabBar") then
        if ImGui.BeginTabItem("Group Signals") then
            self:layoutGroupSignals()
            ImGui.EndTabItem()
        end
        if ImGui.BeginTabItem("Individual Signals") then
            self:layoutIndividualSignals()
            ImGui.EndTabItem()
        end
        ImGui.EndTabBar()
    end
end

function Event_Viewer:layoutGroupSignals()
    ImGui.Text("Registered Group Signals:")

    ImGui.BeginChild("ScrollRegionGroup", ImVec2(0, -ImGui.GetFrameHeightWithSpacing()), 0, ImWindowFlags.HorizontalScrollbar)
    do
        ImGui.PushStyleVar(ImStyleVar.ItemSpacing, ImVec2(4, 1))
        for groupName, g in pairs(core.signals._groups) do
            -- Group-level checkbox, shown inline with the tree node label.
            local changed, newVal = ImGui.Checkbox("##grp_" .. groupName, g.enabled)
            if changed then
                core.signals:SetGroupEnabled(groupName, newVal)
            end
            ImGui.SameLine()

            if ImGui.TreeNode(groupName) then
                local list = g.list
                for i = 1, #list do
                    local e = list[i]
                    if not e.dead then
                        local entryChanged, entryVal = ImGui.Checkbox("##entry_" .. groupName .. "_" .. i, e.enabled)
                        if entryChanged then
                            e.enabled = entryVal
                        end
                        ImGui.SameLine()
                        ImGui.Text(("%d. %s (order: %d)"):format(i, e.name or "<unnamed>", e.order or 0))
                    end
                end
                ImGui.TreePop()
            end
        end
        ImGui.PopStyleVar()
    end
    ImGui.EndChild()
end

function Event_Viewer:layoutIndividualSignals()
    ImGui.Text("Registered Individual Signals:")

    ImGui.BeginChild("ScrollRegionIndividual", ImVec2(0, -ImGui.GetFrameHeightWithSpacing()), 0, ImWindowFlags.HorizontalScrollbar)
    do
        ImGui.PushStyleVar(ImStyleVar.ItemSpacing, ImVec2(4, 1))
        for name, e in pairs(core.signals._individual) do
            if not e.dead then
                local changed, newVal = ImGui.Checkbox("##ind_" .. name, e.enabled)
                if changed then
                    e.enabled = newVal
                end
                ImGui.SameLine()
                ImGui.Text(name)
            end
        end
        ImGui.PopStyleVar()
    end
    ImGui.EndChild()
end

return Event_Viewer