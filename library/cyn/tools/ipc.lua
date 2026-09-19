---Creates a new game object.
lstg.IPC.register("New", function(obj_name, ...)
    local obj = lstg.New(_G[obj_name], ...)
    return lstg.IsValid(obj)
end)

---Executes lua code
lstg.IPC.register("exec", function(code)
    return assert(load(code))()
end)

---Switches to another stage
lstg.IPC.register("stage_goto", function(name)
    --cyn.stage_manager:goto(name)
end)

lstg.IPC.register("quit", function()
    QuitFlag = true
end)

local signals = require("cyn.foundation.signals")

signals:Register("ipc_start", signals.known_signals.GameInit, function()
    lstg.IPC.start("LuaSTGFlux")
end)