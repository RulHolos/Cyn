---@class resource.sound : resource_base
local M = {
    name = "",
    type = "snd",
    volume = 1,
}
resources.sound = M

---Loads a sound from a file. Supports WAV and OGG. OGG format is recommended.
---@param path string
---@return resource.sound Sound
function M.from_file(path)
    local name = resources.get_typed_name("snd", path)

    lstg.LoadSound(name, path)

    local sound = makeInstance(M)
    sound.name = name
    return sound
end

function M:destroy()
    lstg.RemoveResource(lstg.GetResourceStatus(), "snd", self.name)
end

---@return boolean Validity
function M:is_valid()
    local r = lstg.CheckNamedRes("snd", self.name, true)
    return r == true
end

-------------- State

---Sets the volume of this sound.
---@param volume number Volume multiplier [0, 1].
function M:set_volume(volume)
    self.volume = volume
    lstg.SetSEVolume(self.name, volume)
end

---Gets the current volume of this sound.
---@return number Volume [0, 1]
function M:get_volume()
    return self.volume
end

---Gets the current state of this sound.
---@return "paused"|"playing"|"stopped" State
function M:get_state()
    return lstg.GetSoundState(self.name)
end

-------------- Methods

---Plays this sound.
---@param volume number? Volume multiplier [0, 1]. If nil, uses the sound's default volume.
---@param pan number? Stereo pan (-1 for left, 0 for center, 1 for right). Defaults to 0.
function M:play(volume, pan)
    lstg.PlaySound(self.name, volume or self.volume or 1, pan or 0)
end

---Stops this sound.
function M:stop()
    lstg.StopSound(self.name)
end

---Pauses this sound.
function M:pause()
    lstg.PauseSound(self.name)
end

---Resumes this sound if it was paused.
function M:resume()
    lstg.ResumeSound(self.name)
end