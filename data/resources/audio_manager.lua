---Audio Manager. Handles loading musics and sound effects.
---Can be used to store sounds and musics to play them later more easily than loading them each time.

local audio_manager = {
    ---@type table<string, resource.sound>
    sounds = {},
    ---@type table<string, resource.music>
    musics = {},
}
audio_manager.__index = audio_manager
resources.audio_manager = audio_manager

local se_path = "assets/se/"

---Loads all sound effects in the assets se directory.
---
---If a .json file exists in that folder, it will try and load it, and use it to set the initial volume of sound effects.
---Ohterwise, will put them all to default.
function audio_manager.load_se()
    local se_volumes = {}
    local f, msg = io.open("assets/se/se.json", 'r')
    if f then
        se_volumes = json.deserialize(f:read("*a"))
        f:close()
    else
        error("Couldn't load sound effects data. File not readable.")
    end

    for k, v in pairs(se_volumes) do
        if type(v) ~= "number" then
            error("Invalid sound effect volume data. Expected a number, got " .. type(v))
        end
        local full_path = se_path .. "se_" .. k .. ".wav"

        local res = resources.sound.from_file(full_path)
        if res then
            res:set_volume(v)
            audio_manager.sounds[k] = res
        else
            print(0, "Failed to load sound effect " .. k .. " from " .. full_path)
        end
    end
end

---Plays a loaded sound effect by name.
---@param name string Sound effect name, without the "se_" prefix or file extension.
---@param volume number? Volume multiplier [0, 1]. If nil, uses the sound's default volume.
---@param pan number? Stereo pan (-1 for left, 0 for center, 1 for right). Defaults to 0.
function audio_manager.play_se(name, volume, pan)
    local sound = audio_manager.sounds[name]
    if sound then
        sound:play(volume, pan)
    else
        print("Sound effect " .. name .. " not found.")
    end
end

audio_manager.load_se()

return audio_manager