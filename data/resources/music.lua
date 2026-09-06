---@class resource.music : resource_base
local M = {
    name = "",
    type = "bgm",
    volume = 1,
}
resources.music = M

---Loads a music from a file. Supports WAV and OGG. OGG format is recommended.
---@param path string
---@param loop_end_sec number? Loop end time in seconds. If 0 or nil, the music will loop from the end back to the beginning.
---@param loop_duration_sec number? Loop duration in seconds. If 0 or nil, the loop will be seamless.
---@return resource.music Music
function M.from_file(path, loop_end_sec, loop_duration_sec)
    local name = resources.get_typed_name("bgm", path)

    lstg.LoadMusic(name, path, loop_end_sec or 0, loop_duration_sec or 0)

    local music = makeInstance(M)
    music.name = name
    return music
end

function M:destroy()
    lstg.RemoveResource(self._pool, "bgm", self.name)
end

---@return boolean Validity
function M:is_valid()
    local r = lstg.CheckNamedRes("bgm", self.name, true)
    return r == true
end

-------------- State

---Sets the volume of this music.
---@param volume number Volume multiplier [0, 1].
function M:set_volume(volume)
    self.volume = volume
    lstg.SetBGMVolume(self.name, volume)
end

---Gets the current volume of this music.
---@return number Volume [0, 1]
function M:get_volume()
    return self.volume
end

---Gets the current state of this music.
---@return "paused"|"playing"|"stopped" State
function M:get_state()
    return lstg.GetMusicState(self.name)
end

-------------- Methods

---Plays this music.
---@param volume number? Volume multiplier [0, 1]. If nil, uses the music's default volume.
---@param pan number? Stereo pan (-1 for left, 0 for center, 1 for right). If nil, defaults to 0 (center).
function M:play(volume, pan)
    lstg.PlayMusic(self.name, volume or self.volume or 1, pan or 0)
end

---Stops this music.
function M:stop()
    lstg.StopMusic(self.name)
end

---Pauses this music.
function M:pause()
    lstg.PauseMusic(self.name)
end

---Resumes this music if it was paused.
function M:resume()
    lstg.ResumeMusic(self.name)
end