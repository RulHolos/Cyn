---Audio Manager. Handles loading musics and sound effects.
---Can be used to store sounds and musics to play them later more easily than loading them each time.

local audio_manager = {}
audio_manager.__index = audio_manager

function audio_manager.new()
    local self = makeInstance(audio_manager)
    self.sounds = {}
    self.musics = {}
    resources.audio_manager = self
    return self
end