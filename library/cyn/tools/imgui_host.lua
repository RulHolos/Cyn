local imgui_exists, imgui = pcall(require, "imgui")
local ImVec4 = imgui.ImVec4
local ImVec2 = imgui.ImVec2
local signals = require("cyn.foundation.signals")
local bor = bit.bor

---@class cyn.imgui.layer
---@field frame? fun(self: table)
---@field layout fun(self: table)
---@field isActive? fun(self: table): boolean?

local M = {
    layers = {}
}

---@param name string
---@param layer table Needs layout(); optional frame() and isActive().
---@param order number? Lower draws first.
function M:register(name, layer, order)
    for i, l in ipairs(self.layers) do
        if l.name == name then
            table.remove(self.layers, i)
            break
        end
    end
    table.insert(self.layers, { name = name, layer = layer, order = order or 0 })
    table.sort(self.layers, function(a, b) return a.order < b.order end)
end

function M:isActive()
    for _, l in ipairs(self.layers) do
        if l.layer.isActive and l.layer:isActive() then
            return true
        end
    end
    return false
end

local function set_style()
    local style = imgui.ImGui.GetStyle()
    local colors = style.Colors

    colors[imgui.ImGuiCol.Text] = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.ImGuiCol.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00);
    colors[imgui.ImGuiCol.WindowBg] = ImVec4(0.10, 0.10, 0.10, 0.90);
    colors[imgui.ImGuiCol.ChildBg] = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.ImGuiCol.PopupBg] = ImVec4(0.19, 0.19, 0.19, 0.92);
    colors[imgui.ImGuiCol.Border] = ImVec4(0.19, 0.19, 0.19, 0.29);
    colors[imgui.ImGuiCol.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.24);
    colors[imgui.ImGuiCol.FrameBg] = ImVec4(0.05, 0.05, 0.05, 0.54);
    colors[imgui.ImGuiCol.FrameBgHovered] = ImVec4(0.19, 0.19, 0.19, 0.54);
    colors[imgui.ImGuiCol.FrameBgActive] = ImVec4(0.20, 0.22, 0.23, 1.00);
    colors[imgui.ImGuiCol.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.TitleBgActive] = ImVec4(0.06, 0.06, 0.06, 1.00);
    colors[imgui.ImGuiCol.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.MenuBarBg] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[imgui.ImGuiCol.ScrollbarBg] = ImVec4(0.05, 0.05, 0.05, 0.54);
    colors[imgui.ImGuiCol.ScrollbarGrab] = ImVec4(0.34, 0.34, 0.34, 0.54);
    colors[imgui.ImGuiCol.ScrollbarGrabHovered] = ImVec4(0.40, 0.40, 0.40, 0.54);
    colors[imgui.ImGuiCol.ScrollbarGrabActive] = ImVec4(0.56, 0.56, 0.56, 0.54);
    colors[imgui.ImGuiCol.CheckMark] = ImVec4(0.33, 0.67, 0.86, 1.00);
    colors[imgui.ImGuiCol.SliderGrab] = ImVec4(0.34, 0.34, 0.34, 0.54);
    colors[imgui.ImGuiCol.SliderGrabActive] = ImVec4(0.56, 0.56, 0.56, 0.54);
    colors[imgui.ImGuiCol.Button] = ImVec4(0.05, 0.05, 0.05, 0.54);
    colors[imgui.ImGuiCol.ButtonHovered] = ImVec4(0.19, 0.19, 0.19, 0.54);
    colors[imgui.ImGuiCol.ButtonActive] = ImVec4(0.20, 0.22, 0.23, 1.00);
    colors[imgui.ImGuiCol.Header] = ImVec4(0.00, 0.00, 0.00, 0.52);
    colors[imgui.ImGuiCol.HeaderHovered] = ImVec4(0.00, 0.00, 0.00, 0.36);
    colors[imgui.ImGuiCol.HeaderActive] = ImVec4(0.20, 0.22, 0.23, 0.33);
    colors[imgui.ImGuiCol.Separator] = ImVec4(0.28, 0.28, 0.28, 0.29);
    colors[imgui.ImGuiCol.SeparatorHovered] = ImVec4(0.44, 0.44, 0.44, 0.29);
    colors[imgui.ImGuiCol.SeparatorActive] = ImVec4(0.40, 0.44, 0.47, 1.00);
    colors[imgui.ImGuiCol.ResizeGrip] = ImVec4(0.28, 0.28, 0.28, 0.29);
    colors[imgui.ImGuiCol.ResizeGripHovered] = ImVec4(0.44, 0.44, 0.44, 0.29);
    colors[imgui.ImGuiCol.ResizeGripActive] = ImVec4(0.40, 0.44, 0.47, 1.00);
    colors[imgui.ImGuiCol.Tab] = ImVec4(0.00, 0.00, 0.00, 0.52);
    colors[imgui.ImGuiCol.TabHovered] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[imgui.ImGuiCol.TabSelected] = ImVec4(0.20, 0.20, 0.20, 0.36);
    colors[imgui.ImGuiCol.TabDimmed] = ImVec4(0.00, 0.00, 0.00, 0.52);
    colors[imgui.ImGuiCol.TabDimmedSelected] = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[imgui.ImGuiCol.DockingPreview] = ImVec4(0.33, 0.67, 0.86, 1.00);
    colors[imgui.ImGuiCol.DockingEmptyBg] = ImVec4(1.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.PlotLines] = ImVec4(1.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.PlotLinesHovered] = ImVec4(1.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.PlotHistogram] = ImVec4(1.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.PlotHistogramHovered] = ImVec4(1.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.TableHeaderBg] = ImVec4(0.00, 0.00, 0.00, 0.52);
    colors[imgui.ImGuiCol.TableBorderStrong] = ImVec4(0.00, 0.00, 0.00, 0.52);
    colors[imgui.ImGuiCol.TableBorderLight] = ImVec4(0.28, 0.28, 0.28, 0.29);
    colors[imgui.ImGuiCol.TableRowBg] = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.ImGuiCol.TableRowBgAlt] = ImVec4(1.00, 1.00, 1.00, 0.06);
    colors[imgui.ImGuiCol.TextSelectedBg] = ImVec4(0.20, 0.22, 0.23, 1.00);
    colors[imgui.ImGuiCol.DragDropTarget] = ImVec4(0.33, 0.67, 0.86, 1.00);
    colors[imgui.ImGuiCol.NavCursor] = ImVec4(1.00, 0.00, 0.00, 1.00);
    colors[imgui.ImGuiCol.NavWindowingHighlight] = ImVec4(1.00, 0.00, 0.00, 0.70);
    colors[imgui.ImGuiCol.NavWindowingDimBg] = ImVec4(1.00, 0.00, 0.00, 0.20);
    colors[imgui.ImGuiCol.ModalWindowDimBg] = ImVec4(0.10, 0.10, 0.10, 0.00);

    style.WindowPadding = ImVec2(8.00, 8.00);
    style.FramePadding = ImVec2(5.00, 2.00);
    style.CellPadding = ImVec2(6.00, 6.00);
    style.ItemSpacing = ImVec2(6.00, 6.00);
    style.ItemInnerSpacing = ImVec2(6.00, 6.00);
    style.TouchExtraPadding = ImVec2(0.00, 0.00);
    style.IndentSpacing = 25;
    style.ScrollbarSize = 15;
    style.GrabMinSize = 10;
    style.WindowBorderSize = 1;
    style.ChildBorderSize = 1;
    style.PopupBorderSize = 1;
    style.FrameBorderSize = 1;
    style.TabBorderSize = 1;
    style.WindowRounding = 7;
    style.ChildRounding = 4;
    style.FrameRounding = 3;
    style.PopupRounding = 4;
    style.ScrollbarRounding = 9;
    style.GrabRounding = 3;
    style.LogSliderDeadzone = 4;
    style.TabRounding = 4;
end

if imgui_exists then
    local ImGui = imgui.ImGui
    local io = ImGui.GetIO()
    io.ConfigFlags = bor(io.ConfigFlags, imgui.ImGuiConfigFlags.DockingEnable)

    set_style()

    signals:Register("ImGuiHostFrame", signals.known_signals.BeforeFrameFunc, function()
        imgui.backend.NewFrame(M:isActive())
        for _, l in ipairs(M.layers) do
            if l.layer.frame then l.layer:frame() end
        end
    end, signals.LOW_PRIORITY, M)

    signals:Register("ImGuiHostLayout", signals.known_signals.AfterFrameFunc, function()
        ImGui.NewFrame()
        for _, l in ipairs(M.layers) do l.layer:layout() end
        ImGui.EndFrame()
    end, signals.LOW_PRIORITY, M)

    signals:Register("ImGuiHostRender", signals.known_signals.RenderFunc, function()
        ImGui.Render()
        imgui.backend.RenderDrawData()
    end, signals.LOW_PRIORITY, M)
end

return M
