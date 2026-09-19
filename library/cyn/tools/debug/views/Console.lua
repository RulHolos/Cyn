local imgui_exists, imgui = pcall(require, "imgui")

local ImGui = imgui.ImGui
local ImVec2 = imgui.ImVec2
local ImKey = imgui.ImGuiKey
local ImWindowFlags = imgui.ImGuiWindowFlags
local ImInputTextFlags = imgui.ImGuiInputTextFlags
local ImTextBuffer = imgui.ImGuiTextBuffer
local ImStyleVar = imgui.ImGuiStyleVar

local oldLog = lstg.Log
local logs = {}
local levels = {'[D] ', '[I] ', '[W] ', '[E] ', '[F] '}

---@param level cyn.global.LOG
---@param text string
---@diagnostic disable-next-line: duplicate-set-field Conscious override
function lstg.Log(level, text)
    oldLog(level, text)

    logs[#logs + 1] = levels[level] .. text
end

local log = lstg.Log

function print(...)
    local s = tostring(select(1, ...))
    for i = 2, select("#", ...) do
        s = s .. '\t' .. tostring(select(i, ...))
    end
    log(LOG.INFO, s)
end

lstg.Print = print

local inputbuf = ImTextBuffer()
inputbuf:resize(1024)

local function xpcall_handler(err)
    return debug.traceback(err)
end

---@class lstg.debug.view.Console : lstg.debug.view
local Console = {}

function Console:getWindowName() return "Console" end
function Console:getMenuGroup() return "Tools" end
function Console:getViewId() return "view.Console" end
function Console:getEnabled() return self.enabled end
---@param v boolean
function Console:setState(v) self.enabled = v end

function Console:frame() end
function Console:layout()
    ImGui.Text('Enter lua code, prefix with "=" to return its value')

    local footer_h = ImGui.GetStyle().ItemSpacing.y + ImGui.GetFrameHeightWithSpacing()
    ImGui.BeginChild('ScrollRegion', ImVec2(0, -footer_h), 0, ImWindowFlags.HorizontalScrollbar)
    do
        ImGui.PushStyleVar(ImStyleVar.ItemSpacing, ImVec2(4, 1))
        for i = 1, #logs do
            ImGui.TextUnformatted(logs[i])
        end
        ImGui.PopStyleVar()
    end
    ImGui.EndChild()
    ImGui.Separator()

    local input_text_flags = ImInputTextFlags.EnterReturnsTrue

    local reclaim_focus = false
    if ImGui.InputText("Input", inputbuf, 1024, input_text_flags) then
        ---@type string
        local s = inputbuf:c_str()
        local r = s:sub(1, 1) == "="
        if r then
            s = "return " .. s:sub(2)
        end

        if #s > 0 then
            logs[#logs + 1] = "> " .. s

            local f, err = loadstring(s)
            if f == nil then
                logs[#logs + 1] = err
                return
            end
            local success, result = xpcall(f, xpcall_handler)
            if not success then
                logs[#logs + 1] = result
                return
            end
            if r then
                logs[#logs + 1] = "= " .. tostring(result)
            else
                logs[#logs + 1] = ' success'
            end
            inputbuf:clear()
            inputbuf:resize(1024)
            reclaim_focus = true
        end
    end

    ImGui.SetItemDefaultFocus()
    if reclaim_focus then
        ImGui.SetKeyboardFocusHere(-1)
    end
end

return Console
