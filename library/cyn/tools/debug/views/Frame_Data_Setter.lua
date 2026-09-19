---@diagnostic disable: need-check-nil, param-type-mismatch
local imgui_exists, imgui = pcall(require, "imgui")

local ImGui = imgui.ImGui
local ImVec2 = imgui.ImVec2
local ImWindowFlags = imgui.ImGuiWindowFlags
local ImStyleVar = imgui.ImGuiStyleVar

local layer_keys = nil
local layer_values = nil

local function ensure_layer_list()
    if layer_keys then return end
    layer_keys = {}
    layer_values = {}
    for k in pairs(cyn.object.layer) do
        table.insert(layer_keys, k)
    end
    table.sort(layer_keys, function(a, b)
        return cyn.object.layer[a] < cyn.object.layer[b]
    end)
    for i, k in ipairs(layer_keys) do
        layer_values[i] = cyn.object.layer[k]
    end
end

---@class lstg.debug.view.Frame_Data_Setter : lstg.debug.view
local Frame_Data_Setter = {
    _render_layers = {},
}

function Frame_Data_Setter:getWindowName() return "Frame Data Setter" end
function Frame_Data_Setter:getMenuGroup() return "Tools" end
function Frame_Data_Setter:getViewId() return "view.Frame_Data_Setter" end
function Frame_Data_Setter:getEnabled() return self.enabled end
---@param v boolean
function Frame_Data_Setter:setState(v) self.enabled = v end

function Frame_Data_Setter:frame() end

function Frame_Data_Setter:layout()
    self:layout_frame_groups()
    ImGui.Separator()
    self:layout_frame_world()
    ImGui.Separator()
    self:layout_render_layers()
end

local function group_list_contains(v)
    for _, g in ipairs(debug_data.frame_groups) do
        if g == v then return true end
    end
    return false
end

local function group_list_remove(v)
    for i, g in ipairs(debug_data.frame_groups) do
        if g == v then
            table.remove(debug_data.frame_groups, i)
            return
        end
    end
end

function Frame_Data_Setter:layout_frame_groups()
    ImGui.Text("Frame Groups")
    for k, v in pairs(cyn.object.group) do
        local checked = group_list_contains(v)
        local changed, new_val = ImGui.Checkbox(("%s (%d)"):format(k, v), checked)
        if changed then
            if new_val then
                table.insert(debug_data.frame_groups, v)
            else
                group_list_remove(v)
            end
        end
    end
end

function Frame_Data_Setter:layout_frame_world()
    local changed, new_val = ImGui.InputInt("Frame World", debug_data.frame_world)
    if changed then
        debug_data.frame_world = new_val
    end
end

local function sync_render_layers(pairs_ui)
    local flat = {}
    for _, pair in ipairs(pairs_ui) do
        local a = layer_values[pair[1]]
        local b = layer_values[pair[2]]
        if a <= b then
            flat[#flat + 1] = a
            flat[#flat + 1] = b
        else
            flat[#flat + 1] = b
            flat[#flat + 1] = a
        end
    end
    debug_data.render_layers = flat
end

function Frame_Data_Setter:layout_render_layers()
    ensure_layer_list()
    ImGui.Text("Render Layers")

    local to_remove = nil
    local dirty = false
    for i, pair in ipairs(self._render_layers) do
        ImGui.PushID(i)

        ImGui.SetNextItemWidth(160)
        if ImGui.BeginCombo("##from", layer_keys[pair[1]]) then
            for j, key in ipairs(layer_keys) do
                local is_selected = (j == pair[1])
                if ImGui.Selectable(key, is_selected) then
                    pair[1] = j
                    dirty = true
                end
                if is_selected then ImGui.SetItemDefaultFocus() end
            end
            ImGui.EndCombo()
        end

        ImGui.SameLine()
        ImGui.Text("..")
        ImGui.SameLine()

        ImGui.SetNextItemWidth(160)
        if ImGui.BeginCombo("##to", layer_keys[pair[2]]) then
            for j, key in ipairs(layer_keys) do
                local is_selected = (j == pair[2])
                if ImGui.Selectable(key, is_selected) then
                    pair[2] = j
                    dirty = true
                end
                if is_selected then ImGui.SetItemDefaultFocus() end
            end
            ImGui.EndCombo()
        end

        ImGui.SameLine()
        if ImGui.SmallButton("X") then
            to_remove = i
        end

        ImGui.PopID()
    end

    if to_remove then
        table.remove(self._render_layers, to_remove)
        dirty = true
    end

    if dirty then
        sync_render_layers(self._render_layers)
    end

    if ImGui.Button("+ Add Layer Pair") then
        table.insert(self._render_layers, { 1, 1 })
        sync_render_layers(self._render_layers)
    end
end

return Frame_Data_Setter