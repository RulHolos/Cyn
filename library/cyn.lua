---@type lstg
lstg = lstg or {}
--If that fallback triggers, what the FUCK?????

require("cyn.global_scripts.std") --Only thing loaded by default aside from the main loop.

require("cyn.engine.mainloop")

--What are you looking for? The Entry Point? Well good job, you found it.
--Actual engine callbacks are in "cyn/engine/mainloop.lua" tho.

--[[
This is the flow of the engine paired with Cyn:

1. config.json is read, or launch or launch.lua
2. After parsing of the config or launch.lua is done, this file is read. std is loaded and mainloop is loaded.
3. GameInit() is called.
4. Right after GameInit(), Cyn will try to load the game specified in the config or launch file. GameInit() emits the "GameInit" signal.
4.a: If your setting file doesn't have a specified game (the `game` field), Cyn will look in the "game" folder for a single game folder or zip.
4.b: If there are multiple games in the "game" folder, Cyn will not load any and will throw an error.
4.c: You can specify a default game with the `default_game` argument when launching the engine. Will be set by LunaForge automatically. Won't work on SharpX by default.
5. Your game loads a preset or individual scripts as needed in the root.lua.
6. Your game is loaded. The rest of the library's initialization will begin.
7. Main loop begins, FrameFunc() is called and then RenderFunc() each frame one after the other. Each ones emits the "FrameFunc" and "RenderFunc" signals.
8. When the main loop ends, GameExit() is called, which emits the "GameExit" signal.
9. Engine cleans itself up like a toddler.
]]

--[[
Cyn naming convention:
- Class/module type : PascalCase (e.g., MyClass, MyModule)
- Methods/functions : snake_case (e.g., my_function, another_method)
- Constants: All Caps (e.g., MY_CONSTANT)
- Private fields/methods: leading underscore (e.g., _my_private_field, _my_private_method)
- Table fields: snake_case (e.g., my_field, another_field)
- Local variables: snake_case (e.g., my_variable, another_variable)
- Module-level variables: snake_case (e.g., my_module_variable, another_module_variable)
- Signal Groups: PascalCase (e.g., GameInit, FrameFunc)
- Enums: PascalCase (e.g., Direction, GameState)
- Class names: snake_case
]]