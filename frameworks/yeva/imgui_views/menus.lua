local imgui_exists, imgui = pcall(require, "imgui")
if not imgui_exists then
    return
end
local ImGui = imgui.ImGui

local manager = require("cyn.tools.debug")

manager:addMenu("yeva.tools", "Yeva/Tools", function() end)

manager:addMenu("yeva.options", "Yeva/Options", function() end)

--manager:addMenu("yeva.debuggers", "Yeva/Debuggers", function() end)
