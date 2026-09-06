---@type lstg
lstg = lstg or {}

require("core.global_scripts.std")
require("resources") -- Resource wrappers.
require("core") -- Core of the library
require("content") -- Actual game contents (players, bosses, enemis, bullets, ...)

--What are you looking for? The Entry Point? Well good job, you found it.
--Actual engine callbacks are in "core/mainloop.lua" tho.