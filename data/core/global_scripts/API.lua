---@meta API

---Functions documentation made by Rül Hölos.
---Documentation updated for Flux v0.4.0. Contains all API calls available.

---base class of all classes
---@class lstg.object
---@field x number x position
---@field y number y position
---@field dx number x position difference from last update (read-only)
---@field dy number y position difference from last update (read-only)
---@field rot number Object orientation in degrees.
---@field omiga number Angular velocity of orientation.
---@field timer integer Frame timer.
---@field vx number x velocity.
---@field vy number y velocity.
---@field ax number x acceleration.
---@field ay number y acceleration.
---@field layer number Render layer. (see lib/Lobject.lua)
---@field group number Collision group. (see lib/Lobject.lua)
---@field hide boolean If true, the object will not be rendered.
---@field bound boolean If false, the object will not be taken into account for boundary checks.
---@field navi boolean If true, the object's `rot` will be updated according to velocity.
---@field colli boolean If false, the object will not be taken into account for collision checks.
---@field status "del"|"kill"|"normal" The current status of the object.
---@field hscale number Horizontal scale.
---@field vscale number Vertical scale.
---@field class any Class of the object.
---@field a number x collision.
---@field b number y collision.
---@field rect boolean If true, the collision box will be rectangular. Otherwise; circular or oval.
---@field img string Name of the renderable resource on the object.
---@field ani integer Animation timer (read_only)
---@field world integer The world this object belongs to.
---@field is_class boolean Always true.
---@field init fun(...)
---@field del fun(...)
---@field frame fun(...)
---@field render fun(...)
---@field kill fun(...)

---Represents a color object in ARGB format. Range is [0, 255]
---@class lstg.Color
---@overload fun(argb:number) : lstg.Color
---@overload fun(a:number, r:number, g:number, b:number)
---@field a number alpha component
---@field r number red component
---@field g number green component
---@field b number blue component
---@field ARGB fun(self:lstg.Color) : number, number, number, number Returns a, r, g, b components respectively
---@operator add(lstg.Color) : lstg.Color Adds two colors and returns the result.
---@operator sub(lstg.Color) : lstg.Color Substracts two colors and returns the result.
---@operator mul(lstg.Color) : lstg.Color Multiplies two colors together and returns the result.
---@operator div(lstg.Color) : lstg.Color Divides two colors together and returns the result.
---@alias Color lstg.Color

---Represents a random number generator class using the WELL512 algorithm.
---@class RNG
---@field Seed fun(self:RNG, seed:number) Sets the seed. Should be in range [0, 2^32-1].
---@field GetSeed fun(self:RNG) : number Returns the current seed.
---@field Int fun(self:RNG, min:integer, max:integer) : integer Returns a random integer in range [min, max]. `min` shouldn't be bigger than `max`.
---@field Float fun(self:RNG, min:number, max:number) : number Returns a random float in range [min, max]. `min` shouldn't be bigger than `max`.
---@field Sign fun(self:RNG) : number Returns either 1 or -1 randomly.

---Represents a Bent Laser object.
---@class BentLaserData
---@field Update fun(self:BentLaserData, obj:any, length:number, width:number, deactive:boolean?) Add a new node to a bent laser. It's position will be `(obj.x, obj.y)`
---@field UpdatePositionByList fun(...) Undocumented
---@field Release fun() Legacy function, obsolete in Sub. Does nothing.
---@field Render fun(self:BentLaserData, texName:string, blend:BlendMode, color:lstg.Color, texLeft:number, texTop:number, texWidth:number, texHeight:number, scale:number) Render a bent laser with specified parameters.
---@field CollisionCheck fun(self:BentLaserData, x:number, y:number, rot:number?, a:number?, b:number?, rect:boolean?) : boolean Checks for collision with a fake game object. Returns true if colliding. Optional circle colliders.
---@field BoundCheck fun(self:BentLaserData) : boolean Check if all nodes positions are in the range set by `SetBound()`. Returns true if all of the laser is inside bounds.

---Represents a Stop Watch object, useful for timers for example.
---@class StopWatch
---@field Reset fun() : self Reset the stopwatch to 0.
---@field Pause fun() : self Pauses the stopwatch
---@field Resume fun() : self Resumes the stopwatch
---@field GetElapsed fun() : number Returns the elapsed time (in seconds).

---Represents the engine file manager.
---@class lstg.FileManager
---@field LoadArchive fun(path:string, password:string?) Loads an zip/rar archive from a path with an optional password.
---@field UnloadArchive fun(path:string) Unloads a zip/rar archive from a path.
---@field UnloadAllArchive fun() Unloads all loaded archives.
---@field ArchiveExist fun(path:string) : boolean Returns true if the specified archive exists.
---@field GetArchive fun(path:string) : any Gets the archive specified by the path.
---@field EnumArchives fun() : table Enumerates all the archives currently loaded.
---@field EnumFiles fun(search_path:string, extension:string?, include_archives:boolean?) : table<string> Enumerates and returns all the files paths matching the extension in `search_path`.
---@field EnumFilesEx fun(search_path:string, extension:string?) : table<string> Enumerated and returns all the files matching the extension in `search_path` including archives.
---@field FileExist fun(path:string, all:boolean?) : boolean Returns `true` if the file exists at `path` .
---@field FindFiles fun(search_path:string, extension:string?) Same as `EnumFiles` but for archives.
---@field AddSearchPath fun(path:string) Adds a path to allow the engine to search source files in.
---@field RemoveSearchPath fun(path:string) Removes a path to allow the engine to search source files in.
---@field ClearSearchPath fun() Removes all the search paths stored in the engine. Not recommended.
---@field SetCurrentDirectory fun(path:string) Sets the current working directory. Crashes if the directory doesn't exist.
---@field GetCurrentDirectory fun() : string Returns the current working directory.
---@field CreateDirectory fun(path:string) Creates a directory at the specified path.
---@field RemoveDirectory fun(path:string) Deletes the directory and all its content.
---@field DirectoryExists fun(path:string) : boolean Returns true if the specified directory exists.

---@alias ResourceType
---| 1 Texture
---| 2 Sprite
---| 3 Animation
---| 4 Music
---| 5 SoundEffect
---| 6 Particle
---| 7 SpriteFont
---| 8 TTF
---| 9 Shader
---| 10 Model
---| 11 Video

---@alias SamplerState "point+wrap"|"point+clamp"|"linear+wrap"|"linear+clamp"
---@alias LogLevel
---| 0 debug
---| 1 info
---| 2 warn
---| 3 error
---| 4 fatal

---@alias lstg.BlendMode ""|"mul+alpha"|"mul+add"|"mul+rev"|"mul+sub"|"add+alpha"|"add+add"|"add+rev"|"add+sub"|"alpha+bal"|"mul+min"|"mul+max"|"mul+mul"|"mul+screen"|"add+min"|"add+max"|"add+mul"|"add+screen"|"one"
---@alias BlendMode lstg.BlendMode

---@alias playableState "paused"|"playing"|"stopped"

---Represents the base engine defined functions and API calls.
---@class lstg
---@field args string Arguments passed by the engine, got from command line launches. If launched from an executable, it will be an empty string.
---
---Submodules
---@field FileManager lstg.FileManager
---@field Color lstg.Color
---@field RichText lstg.RichText
---@field Renderer lstg.Renderer
---@field Clipboard lstg.Clipboard
---@field Display lstg.Display
---@field Window lstg.Window
---@field DiscordRPC lstg.DiscordRPC
---@field Texture2D lstg.Texture2D
---@field Sprite lstg.Sprite
---
---Constructors
---@field Rand fun() : RNG Creates a RNG object.
---@field StopWatch fun() : StopWatch Creates a StopWatch object.
---@field BentLaserData fun() : BentLaserData Creates a BentLaserData object.
---
---Resource Pool
---@field SetResLoadInfo fun(active:boolean) Activate or deactivate logging for loading resources.
---@field CreateResourcePool fun(name:string) Creates a resource pool for loading resource. Can be used in `SetResourceStatus` and `RemoveResource`.
---@field RemoveResourcePool fun(name:string) Deletes a resource pool and frees all the resources created in its scope.
---@field SetResourceStatus fun(pool:string) Set a scope pool for loading resources.
---@field GetResourceStatus fun() : string Returns the current scope pool for loading resources.
---@field RemoveResource fun(poolType:string) Clears a resource pool. If a resource is in use, it will not be freed until it's not used anymore.
---@field RemoveResource fun(poolType:string, resType:ResourceType, name:string) Removes a resource from a pool. If a resource is in use, it will not be freed until it's not used anymore.
---@field CheckRes fun(resType:ResourceType, name:string) : string Returns name of the pool where a resource is located. Usually used to check if a resource exists.
---@field EnumRes fun(resType:ResourceType) : table, table Returns array of all the resource names in `global` and `stage` pools respectively.
---@field ResetPool fun() Deletes all game objects marked to be deleted or killed immediately.
---@field TransferResource fun(src:string, dest:string, resType:ResourceType, resName:string) Transfers a resource from one pool to another.
---
---Resource Loaders
---@field CreateRenderTarget fun(name:string, width:number?, height:number?) Creates a render target. Will be treated as a texture resource.
---@field LoadTexture fun(name:string, path:string, mipmap:boolean?) Loads a texture resource from a file.
---@field LoadImage fun(name:string, tex_name:string, x:number, y:number, width:number, height:number, a:number?, b:number?, rect:boolean?) Loads an image from a texture with optional collision parameters.
---@field LoadAnimation fun(name:string, tex_name:string, x:number, y:number, width:number, height:number, columns:integer, rows:integer, interval:integer, a:number?, b:number?, rect:boolean?) Loads an animation from a texture with optional collision parameters.
---@field LoadPS fun(name:string, def_file:string, img_name:string, a:number?, b:number?, rect:boolean?) Loads a HGE particle from a file with optional collision parameters.
---@field LoadSound fun(name:string, path:string) Loads a sound resource from a file.
---@field LoadMusic fun(name:string, path:string, loop_end:number, loop_duration:number) Loads a music resource. Supports WAV and OGG. OGG format is recommended.
---@field LoadFont fun(name:string, def_file:string, bind_tex:string?, mipmap:boolean?) Loads a texture font resource. Supports HGE and fancy2d formats. For HGE, provide `bind_tex` for the image file.
---@field LoadTTF fun(name:string, path:string, width:number, height:number?) Loads a TTF font resource. `width` specifies the font size.
---@field LoadFX fun(name:string, path:string) Loads a shader resource. The shader format should be `hlsl`.
---@field LoadModel fun(name:string, path:string) Loads a model. Supported formats are `gltf`, `glb`.
---@field LoadVideo fun(name:string, path:string) Loads a video resource from a file. Supported formats are `mp4`, `mov`, `mkv`, `avi`. Make sure to use compatible codecs (MPEG-4 or H-264) for better compatibility.
---
---Async Resource Loaders (Flux only)
---Each async loader accepts a table of request tables, an optional defaults table (same fields, used as fallback), and an optional pool name (`"global"` or `"stage"`, or any other custom pool name).
---All functions return a `lstg.LoadingTask` which can be polled each frame or blocked on with `wait()`.
---@field LoadTextureAsync fun(requests:{name:string, path:string, mipmaps:boolean?, width:integer?, height:integer?}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads textures into a resource pool. Each request requires `name` and `path`.
---@field LoadSpriteAsync fun(requests:{name:string, texture:string, x:number, y:number, w:number, h:number, anchor_x:number?, anchor_y:number?, rect:boolean?}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads sprites into a resource pool. Each request requires `name`, `texture`, `x`, `y`, `w`, `h`.
---@field LoadAnimationAsync fun(requests:{name:string, texture:string, x:number, y:number, w:number, h:number, n:integer, m:integer, interval:integer, anchor_x:number?, anchor_y:number?, rect:boolean?, sprites:string[]?}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads animations into a resource pool. Each request requires `name`, `texture`, `x`, `y`, `w`, `h`, `n`, `m`, `interval`.
---@field LoadMusicAsync fun(requests:{name:string, path:string, loop_start:number?, loop_end:number?, once_decode:boolean?}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads music into a resource pool. Each request requires `name` and `path`.
---@field LoadSoundAsync fun(requests:{name:string, path:string}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads sound effects into a resource pool. Each request requires `name` and `path`.
---@field LoadFontAsync fun(requests:{name:string, path:string, width:number, height:number?}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads TTF fonts into a resource pool. Each request requires `name`, `path`, and `width`.
---@field LoadSpriteFontAsync fun(requests:{name:string, path:string, tex_path:string?, mipmaps:boolean?}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads HGE sprite fonts into a resource pool. Each request requires `name` and `path`.
---@field LoadFXAsync fun(requests:{name:string, path:string}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads shaders into a resource pool. Each request requires `name` and `path`.
---@field LoadModelAsync fun(requests:{name:string, path:string}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads models into a resource pool. Each request requires `name` and `path`.
---@field LoadParticleAsync fun(requests:{name:string, path:string, img_name:string, anchor_x:number?, anchor_y:number?, rect:boolean?}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads HGE particle systems into a resource pool. Each request requires `name`, `path`, and `img_name`.
---@field LoadVideoAsync fun(requests:{name:string, path:string}[], defaults?:table, pool?:string) : lstg.LoadingTask Asynchronously loads videos into a resource pool. Each request requires `name` and `path`.
---@field GetAsyncLoaderThreadCount fun() : integer Returns the number of worker threads used by the async resource loader.
---@field SetAsyncLoaderMaxItemsPerFrame fun(count:integer) Sets the maximum number of GPU upload operations processed per frame by the async loader.
---@field GetAsyncLoaderMaxItemsPerFrame fun() : integer Returns the current maximum GPU upload operations per frame limit.
---@field ClearAsyncLoaderTasks fun() Cancels and removes all pending async loading tasks. Resources already committed to the GPU are not affected.
---
---Resource State
---@field SetTextureSamplerState fun(name:string, sampler_state:SamplerState) Sets the given texture sampler state.
---@field GetTextureSize fun(name:string) : number, number Returns the width and height of a texture resource.
---@field IsRenderTarget fun(name:string) : boolean Returns true if the given texture is a render target texture.
---@field SetImgState fun(object:lstg.object, blend:BlendMode, a:number, r:number, g:number, b:number) Set parameters of the renderable resource bind to `object`. Also see `SetImageState`
---@field SetImageState fun(name:string, blendmode:BlendMode, color:lstg.Color?, color2:lstg.Color?, color3:lstg.Color?, color4:lstg.Color?) Sets the parameters of an image or texture resource.
---@field SetImageCenter fun(name:string, x:number, y:number) Sets center of an image or texture resource, relative to its top-left corner.
---@field SetImageScale fun(name:string, scale:number) Sets the scale of the specified image resource.
---@field SetImageScale fun(scale:number) Sets the global scale of image resources.
---@field GetImageScale fun(name:string) : number Returns the scale of the specified image resource.
---@field SetAnimationState fun(name:string, blendmode:BlendMode, color:lstg.Color?) Sets the parameters of an animation resource.
---@field SetAnimationCenter fun(name:string, x:number, y:number) Sets center of an image or texture resource, relative to its top-left corner.
---@field SetAnimationScale fun(name:string, scale:number) Sets the scale of an animation resource.
---@field GetAnimationScale fun(name:string) : number Returns the scale of an animation resource.
---@field SetFontState fun(name:string, blendmode:BlendMode, color:lstg.Color?) Sets the state of a HGE font.
---@field CacheTTFString fun(name:string, text:string) Pre-cache all glyphs used by the given text in a TTF font.
---@field SetBGMVolume fun(volume:number) Sets the global volume factor. Doesn't affect playing musics.
---@field SetBGMVolume fun(name:string, volume:number) Sets the volume of the specified music resource.
---@field GetMusicState fun(name:string) : playableState Returns the status of a music resource.
---@field SetSEVolume fun(volume:number) Sets the global volume factor. Doesn't affect playing sound effects.
---@field SetSEVolume fun(name:string, volume:number) Sets the volume of the specified sound effect resource.
---@field GetSoundState fun(name:string) : playableState Returns the status of a sound effect resource.
---@field GetVideoState fun(name:string) : playableState Returns the status of a video resource.
---@field GetVideoTime fun(name:string) : number Returns the current play time of a video in seconds.
---@field GetVideoTotalTime fun(name:string) : number Returns the total duration of a video in seconds.
---@field GetVideoSize fun(name:string) : {width:number, height:number} Returns the size of a video.
---@field SetVideoVolume fun(name:string, volume:number) Sets the volume of a video. Volume is in [0, 1] range.
---@field GetVideoVolume fun(name:string) : number Returns the volume of a video. Volume is in [0, 1] range.
---@field SetVideoLoop fun(name:string, loop:boolean) Sets whether a video should loop.
---
---State control
---@field PlayMusic fun(name:string, volume:number?, position:number?) Plays a music with an optional volume in range [0, 1] and starting position in seconds.
---@field StopMusic fun(name:string) Stops a music.
---@field PauseMusic fun(name:string) Pauses a music.
---@field ResumeMusic fun(name:string) Resumes a music.
---@field PlaySound fun(name:string, volume:number, pan:number?) Play a sound effect. Volume is in [0, 1] range. Pan specifies the channel balance in range [-1, 1].
---@field StopSound fun(name:string) Stops a playing sound effect.
---@field PauseSound fun(name:string) Pauses a sound effect.
---@field ResumeSound fun(name:string) Resumes a sound effect.
---@field PlayVideo fun(name:string) Plays a video from the beginning.
---@field StopVideo fun(name:string) Stops a video and resets the play time to the beginning.
---@field PauseVideo fun(name:string) Pauses a video.
---@field ResumeVideo fun(name:string) Resumes a paused video.
---@field SeekVideo fun(name:string, time:number) Seeks a video to the specified time in seconds.
---
---Render Calls
---@field BeginScene fun() Starts drawing the scene and enabled the rendering context.
---@field EndScene fun() Ends drawing the scene and ends the rendering context.
---@field DefaultRenderFunc fun(object:lstg.object) Performs the default render function for a game object.
---@field RenderClear fun(color:lstg.Color) Clears the screen with the specified color. Will also clear the z-buffer if it's enabled.
---@field Render fun(name:string, x:number, y:number, rot:number?, hscale:number?, vscale:number?, z:number?) Renders an image or texture resource to the screen.
---@field RenderRect fun(name:string, left:number, right:number, bottom:number, top:number) Renders an image in the specified rectangle. Z coordinates will be `0.5`.
---@field Render4V fun(name:string, x1:number, y1:number, z1:number, x2:number, y2:number, z2:number, x3:number, y3:number, z3:number, x4:number, y4:number, z4:number) Renders an image in specified vertex position.
---@field Render4V fun(name:string, ...) Renders an image in specified vertex position.
---@field Render3D fun(name:string, x:number, y:number, z:number, rotationx:number, rotationy:number, rotationz:number, scalex:number, scaley:number) Renders a texture in 3D space. Rotation is in degrees.
---@field RenderAnimation fun(name:string, ani_timer:number, x:number, y:number, rot:number?, hscale:number?, vscale:number?, z:number?) Renders an animation.
---@field RenderTexture fun(tex_name:string, blend:BlendMode, vertex1:table<number, number, number, number, number, lstg.Color>, vertex2:table<number, number, number, number, number, lstg.Color>, vertex3:table<number, number, number, number, number, lstg.Color>, vertex4:table<number, number, number, number, number, lstg.Color>) vertex1-4 specify vertices and should have following fields: [1] = X, [2] = Y, [3] = Z, [4] = U, [5] = V, [6] = Color. Renders a texture with custom vertices.
---@field RenderMesh fun(...) Undocumented
---@field RenderModel fun(name:string, x:number, y:number, z:number, roll:number, pitch:number, yaw:number, sx:number, sy:number, sz:number) Renders a model in 3d space. `roll`, `pitch` and `yaw` are in degrees. `sx`, `sy`, `sz` are scale factors.
---@field RenderVideo fun(name:string) Renders a video with its original size. The position of the video is determined by the current viewport and ortho/perspective settings.
---@field RenderVideoRect fun(name:string, left:number, right:number, bottom:number, top:number) Renders a video in the specified rectangle. Z coordinate will be `0.5`.
---@field RenderVideo4V fun(name:string, x1:number, y1:number, x2:number, y2:number, x3:number, y3:number, x4:number, y4:number) Renders a video in specified vertex position.
---@field PushRenderTarget fun(name:string) Push a render target into the stack. Following rendering will be applied to the render texture.
---@field PopRenderTarget fun() Pops the last render target off the stack, resume normal rendering execution.
---@field PopRenderTarget fun(name:string)Pops the given render target off the stack, resume normal rendering execution.
---@field PostEffect fun(name:string, fx_name:string, sampler_type:number, blend:BlendMode, args:table?, args2:table?) Applies a post effect (shader) and renders the result. Values in args will be passed to the shaders. Partially undocumented.
---@field RenderTTF fun(name:string, text:string, left:number, right:number, bottom:number, top:number, format:integer, color:lstg.Color, scale:number?) Renders a text with a TTF font.
---@field RenderText fun(name:string, text:string, x:number, y:number, scale:number?, align:integer?) Renders a text with a HGE font.
---@field RenderGroupCollider fun(group:number, color:lstg.Color) Render all the collider of the given group with a specified color.
---@field SaveTexture fun(name:string, path:string) Saves a texture/rendertarget to a file.
---@field DrawCollider fun() Render all the colliders of all groups of all objects with builtin colors.
---
---Main loop control. With the exception of FPS controls, these functions should not be called in coroutines, as they will cause unexpected behaviors.
---@field SetFPS fun(fps:number) Sets the targeted FPS count. Default is 60.
---@field GetFPS fun() : number Returns the current FPS count.
---@field ObjFrame fun() Peforms the position, acceleration and rotation of all game objects. !! Do not invoke in coroutines !!
---@field ObjRender fun() Renders all the game objects. Will invoke render() one by one. Objects with smaller `layer` will be rendered first. !! Do not invoke in coroutines !!
---@field UpdateXY fun() Updates the dx, dy, lastx, lasty and rot (when navi is `true`) of all game objects. !! Do not invoke in coroutines !!
---@field AfterFrame fun() Update following properties of all objects: timer, ani_timer. Deletes objects marked as `del` or `kill`. !! Do not invoke in coroutines !!
---@field CollisionCheck fun(A:number, B:number) : boolean Performs the collision check between two object groups ids and performs the colli() callback. (see lib/Lobject.lua). !! Do not invoke in coroutines !!
---@field BoundCheck fun() Do boundary checks on all objects. Marks them as `del` if they're out of bounds. !! Do not invoke in coroutines !!
---@field PartialObjFrame fun(group:integer[]?, world:integer?) Performs ObjFrame (V2) on a filtered list of objects. Empty tables means no filter. !! Do not invoke in coroutines !!
---@field PartialObjRender fun(group:integer[]?, layers:integer[]?, world:integer?) Performs ObjRender on a filtered list of objects. Empty tables means no filter. Layers are pairs of ranges. !! Do not invoke in coroutines !!
---
---Viewport
---@field SetViewport fun(left:number, right:number, bottom:number, top:number) Set viewport. Will affect clipping and rendering.
---@field SetScissorRect fun(left:number, right:number, bottom:number, top:number) Enables the Scrissor Rect. Will affect clipping and rendering.
---@field SetOrtho fun(left:number, right:number, bottom:number, top:number) Set the orthogonal projection.
---@field SetPerspective fun(eyeX:number, eyeY:number, eyeZ:number, atX:number, atY:number, atZ:number, upX:number, upY:number, upZ:number, fovy:number, aspect:number, zn:number, zf:number) Sets the 3D perspective.
---
---Engine, window and settings related
---@field GetVersionNumber fun() : integer, integer, integer Returns the current engine version number in <MAJOR, MINOR, PATCH> order.
---@field GetVersionName fun() : string Returns the current engine version name.
---@field SetWindowed fun(isWindowed:boolean) Tells the engine to render the window in windowed if `true`. Otherwise; will be in exclusive fullscreen.
---@field SetVsync fun(isEnable:boolean) Tells the engine to enable or disable VSync (if supported)
---@field SetResolution fun(width:integer, height:integer) Sets the size of the game window. Default is 640x480.
---@field ChangeVideoMode fun(width:integer, height:integer, windowed:boolean, vsync:boolean) : boolean Changes the display parameters. Returns true if success. Otherwise; false, and restore last parameters.
---@field ChangeVideoMode fun(width:integer, height:integer, video_mode:'windowed'|'fullscreen'|'borderless', vsync:boolean) : boolean Changes the display parameters. FLUX ONLY.
---@field EnumResolutions fun() : {width:integer, height:integer, refresh_numerator:integer, refresh_denominator:integer}[] Enumerates built-in resolutions. Returns a table of <width, height, refresh rate numerator, refresh rate denominator>.
---@field EnumGPUs fun() : table<string> Returns a table of the current available GPUs friendly names.
---@field ChangeGPU fun(name:string) Changes the GPU to the one specified by the name. Only works if the system has multiple GPUs and supports GPU switching.
---@field SetTitle fun(title:string) Changes the game title.
---@field SetSplash fun(enabled) If `true`, will display the mouse when hovering the game window.
---
---Particles
---@field SetParState fun(object:lstg.object, blend:BlendMode, a:number, r:number, g:number, b:number) Set parameters of the renderable particules bind to `object`.
---@field ParticleStop fun(object:lstg.object) Stop particle emitter on `object`
---@field ParticleFire fun(object:lstg.object) Start particle emitter on `object`
---@field ParticleGetn fun(object:lstg.object) : number Returns the current particle count on `object`
---@field ParticleGetEmission fun(object:lstg.object) : number Returns the particle emit frequency on `object` (count per second). Particle emitter will always step by 1/60 seconds.
---@field ParticleSetEmission fun(object:lstg.object, count:number) Set the particle emit frequency on `object` (count per second).
---
---Objects control
---@field GetAttr fun(...) Basically __index
---@field SetAttr fun(...) Basically __newindex
---@field BoxCheck fun(object:lstg.object, left:number, right:number, bottom:number, top:number) : boolean Checks if position of `object` is in the given rect.
---@field ColliCheck fun(object:lstg.object, other:lstg.object) : boolean Checks if two objects are intersecting.
---@field Angle fun(a:lstg.object, b:lstg.object) : number Retuns angle between the line connecting two objects in degrees.
---@field Angle fun(x1:number, y1:number, x2:number, y2:number) : number Returns angle between the line connection two points in degrees.
---@field Dist fun(a:lstg.object, b:lstg.object) : number Returns distance between two objects.
---@field Dist fun(x1:number, y1:number, x2:number, y2:number) : number Returns distance between two points.
---@field GetV fun(object:lstg.object) : number, number Returns magnitude (speed) and direction (in degrees) of the object velocity.
---@field SetV fun(object:lstg.object, magnitude:number, direction:number, updateRot:boolean?) Set magnitude (speed) and direction (in degrees) of the object velocity. Will update `rot` if `updateRot` is `true`.
---@field IsSameWorld fun(a:lstg.object, b:lstg.object) : boolean Checks if two objects are in the same world.
---@field New fun(class:any, ...) : any Creates a new game object with properties and returns it.
---@field Kill fun(object:any) Kills an object. Similar to `Del(obj)`
---@field Del fun(object:any) Deletes an object. Similar to `Kill(obj)`
---@field IsValid fun(object:any) : boolean Returns `true` if the object is not dead or killed. Otherwise; `false`.
---@field GetnObj fun() : number Returns the game object count.
---@field SetBound fun(left:number, right:number, bottom:number, top:number) Set screen boundaries for all game objects. 
---@field GetBound fun(): number, number, number, number Returns the current set world bounds in order: left, right, bottom, top. Flux only.
---
---Inputs
---@field GetMouseState fun(button:number) : boolean Checks if the mouse button is pressed. 0/1/2 corresponds to left/middle/right.
---@field GetMousePosition fun() : number, number Gets the mouse position in pixels relative to the bottom left of the window.
---@field GetMouseWheelDelta fun() : integer Returns the last mouse wheel delta.
---@field GetLastKey fun() : number Returns the code of the last pressed key.
---@field GetKeyState fun(code:number) Check if the key corresponding to `code` (based on VK_CODE defined by Windows) is currently pressed.
---
---Worlds
---@field SetWorldFlag fun(n:integer) Set the current world mask.
---@field GetWorldFlag fun() : integer Returns the current world flag.
---@field SetActiveWorlds fun(mask:integer) Set a flag for masking allowed active worlds (64 max).
---@field GetActiveWorlds fun() : integer Returns the current active world bitmask.
---
---Misc
---@field sin fun(ang:number) : number
---@field cos fun(ang:number) : number
---@field asin fun(v:number) : number
---@field acos fun(v:number) : number
---@field tan fun(ang:number) : number
---@field atan fun(ang:number) : number
---@field atan2 fun(y:number, x:number) : number
---@field SetFog fun() Clears the fog
---@field SetFog fun(near:number, far:number, color:lstg.Color?) Set fog effect.
---@field SetZBufferEnable fun(enabled:integer) Enables the ZBuffer.
---@field ClearZBuffer fun(enabled:integer) Clears the ZBuffer.
---@field Log fun(level:LogLevel, message:string) Logs the given text with the given log level.
---@field SystemLog fun(text:string) Logs the given text with INFO level.
---@field Print fun(...) Logs all arguments into separate lines with INFO level.
---@field DoFile fun(path:string, working_dir:string?) Executes the lua script at the given path. Crashes is the file doesn't exist, failed to compile or execute.
---@field LoadTextFile fun(path:string, packname:string?) : string Loads a text file and returns its content. If packname is given, will search into a zip.
---@field Execute fun(path:string, arguments:string?, directory:string?, wait:boolean?) : boolean Executes an external program at path with optional arguments. Returns true on success. !! Dangerous: NOT DEFINED BY DEFAULT IN ENGINE !!
---@field Snapshot fun(file_path:string) Takes a screenshot of the window and saves it to the file path as a PNG file.
---@field SnapshotToTexture fun(texture_name:string) Takes a screenshot of the window and saves it to the specified texture. Overwrites what was in that texture before.
---@field ExtractRes fun(path:string, target:string) Extract files in a pack to the specified path. Will throw an error if failed for any reason.
---@field LoadPack fun(path:string, password:string?) Loads a zip file at `path` with an optional password. Will throw an error if failed for any reason.
---@field UnloadPack fun(path:string) Unloads a zip file at `path` that was already loaded in memory. Will NOT throw an error if failed for any reason.
---@field MessageBox fun(title:string, text:string, flags:integer) : integer Shows a MessageBox on screen. Uses the Win32 MessageBox API for flags.
---@field GetLocalAppDataPath fun() : string Returns the path to %localappdata%.
---@field GetRoamingAppDataPath fun() : string Returns the path to %appdata%.
---@field ObjList fun(group:number, world_flag:integer?) : function Returns an iterator that goes through all objects in a group.
---@field CollectGroup fun(group:integer, checking_world:integer|nil, dest:table) : integer Collects all objects in a group and stores them in the given table. Returns the number of objects collected. If `checking_world` is given, only objects with the same world flag will be collected.
---
---Undocumented
---@field FindFiles fun(...) Undocumented
---@field GetSuperPause fun(...) Undocumented
---@field SetSuperPause fun(...) Undocumented
---@field AddSuperPause fun(...) Undocumented
---@field GetCurrentSuperPause fun(...) Undocumented
---@field ParticleSystemData fun(...) Undocumented
---@field MeshData fun(...) Undocumented

---------------------------------------
---Async loading types (Flux only)
---------------------------------------

---@class lstg.LoadingTask.Result
---@field name string Name of the resource as specified in the request.
---@field success boolean Whether the resource was loaded successfully.
---@field type ResourceType The type of the resource.
---@field error string? Error message, only present when `success` is `false`.

---Represents a resource loading task returned by the async loader functions (e.g. `lstg.LoadTextureAsync`).
---Poll `isCompleted` each frame, or call `wait` to block until done.
---@class lstg.LoadingTask
---@field getId fun(self:lstg.LoadingTask) : integer Returns the unique ID of this task.
---@field getProgress fun(self:lstg.LoadingTask) : integer, integer Returns the number of completed items and the total item count.
---@field isCompleted fun(self:lstg.LoadingTask) : boolean Returns `true` when all resources have finished loading or the task was cancelled.
---@field isCancelled fun(self:lstg.LoadingTask) : boolean Returns `true` if the task was cancelled via `cancel()`.
---@field getStatus fun(self:lstg.LoadingTask) : "pending"|"loading"|"completed"|"failed"|"cancelled" Returns the current status of the task.
---@field cancel fun(self:lstg.LoadingTask) Requests cancellation of the task. Resources already committed to the GPU remain loaded.
---@field wait fun(self:lstg.LoadingTask) Blocks until the task completes or is cancelled. Do not call from the main game loop.
---@field getResults fun(self:lstg.LoadingTask) : lstg.LoadingTask.Result[] Returns an array of result tables, one per requested resource, in submission order.

---Represents an async texture loading task from the Modern API. Returned by `lstg.Texture2D.loadAsync`.
---@class lstg.AsyncTexture2DTask
---@field getProgress fun(self:lstg.AsyncTexture2DTask) : integer, integer Returns the number of completed and total textures.
---@field isCompleted fun(self:lstg.AsyncTexture2DTask) : boolean Returns `true` when all textures have finished loading.
---@field wait fun(self:lstg.AsyncTexture2DTask) Blocks until the task completes or is cancelled.
---@field cancel fun(self:lstg.AsyncTexture2DTask) Cancels the task.
---@field getTextures fun(self:lstg.AsyncTexture2DTask) : lstg.Texture2D[] Returns an array of loaded `Texture2D` objects in submission order. Failed entries are `nil`.

---Represents an async sprite loading task from the Modern API. Returned by `lstg.Sprite.loadAsync`.
---@class lstg.AsyncSpriteTask
---@field getProgress fun(self:lstg.AsyncSpriteTask) : integer, integer Returns the number of completed and total sprites.
---@field isCompleted fun(self:lstg.AsyncSpriteTask) : boolean Returns `true` when all sprites have finished loading.
---@field wait fun(self:lstg.AsyncSpriteTask) Blocks until the task completes or is cancelled.
---@field cancel fun(self:lstg.AsyncSpriteTask) Cancels the task.
---@field getSprites fun(self:lstg.AsyncSpriteTask) : lstg.Sprite[] Returns an array of loaded `Sprite` objects in submission order. Failed entries are `nil`.

---Modern API texture handle. Obtained from `lstg.Texture2D.loadAsync`.
---Not a named resource pool entry — use directly as input to `lstg.Sprite.loadAsync`.
---@class lstg.Texture2D
---@field loadAsync fun(paths:string[], mipmaps:boolean?) : lstg.AsyncTexture2DTask Asynchronously loads textures from file paths. `mipmaps` defaults to `true`. Returns an `AsyncTexture2DTask`.

---Modern API sprite handle. Obtained from `lstg.Sprite.loadAsync`.
---@class lstg.Sprite
---@field loadAsync fun(sprites:{texture:string|lstg.Texture2D, x:number, y:number, w:number, h:number, anchor_x:number?, anchor_y:number?, rect:boolean?}[], defaults?:{texture?:string|lstg.Texture2D, rect?:boolean, anchor_x?:number, anchor_y?:number}) : lstg.AsyncSpriteTask Asynchronously loads sprites from a texture name or Texture2D handle. Returns an `AsyncSpriteTask`.

---------------------------------------
---All of these represents modules that can be loaded, usualy from "modern"(namespace) Sub/Flux functions.
---------------------------------------

---Represents a Vector2. Load using `local vector2 = require("lstg.Vector2")`
---
---Note: Vectors are not serializable.
---@class lstg.Vector2
---@field create fun(x:number, y:number) : lstg.Vector2 Creates a vector2 and returns it.
---@field length fun(self:lstg.Vector2) : number Returns the length of the vector.
---@field angle fun(self:lstg.Vector2) : number Returns the angle of the vector.
---@field normalize fun(self:lstg.Vector2) : lstg.Vector2 Changes this vector to it's normalized values.
---@field normalized fun(self:lstg.Vector2) : lstg.Vector2 Copy this vector and create a new one with normalized values.
---@field dot fun(self:lstg.Vector2, other:lstg.Vector2) : number Returns the dot product of this and another vector.

---Represents a Vector3. Load using `local vector3 = require("lstg.Vector3")`
---Note: Vectors are not serializable.
---@class lstg.Vector3
---@field create fun(x:number, y:number, z:number) : lstg.Vector3 Creates a vector3 and returns it.
---@field length fun(self:lstg.Vector3) : number Returns the length of the vector.
---@field angle fun(self:lstg.Vector3) : number Returns the angle of the vector.
---@field normalize fun(self:lstg.Vector3) : lstg.Vector3 Changes this vector to it's normalized values.
---@field normalized fun(self:lstg.Vector3) : lstg.Vector3 Copy this vector and create a new one with normalized values.
---@field dot fun(self:lstg.Vector3, other:lstg.Vector3) : number Returns the dot product of this and another vector.

---Represents a Vector4. Load using `local vector4 = require("lstg.Vector4")`
---
---Note: Vectors are not serializable.
---@class lstg.Vector4
---@field create fun(x:number, y:number, z:number, w:number) : lstg.Vector4 Creates a vector4 and returns it.
---@field length fun(self:lstg.Vector4) : number Returns the length of the vector.
---@field angle fun(self:lstg.Vector4) : number Returns the angle of the vector.
---@field normalize fun(self:lstg.Vector4) : lstg.Vector4 Changes this vector to it's normalized values.
---@field normalized fun(self:lstg.Vector4) : lstg.Vector4 Copy this vector and create a new one with normalized values.
---@field dot fun(self:lstg.Vector4, other:lstg.Vector4) : number Returns the dot product of this and another vector.

---@enum lstg.FileSystemWatcher.FileAction
local FileAction = {
    added = 1,
    removed = 2,
    modified = 3,
    renamed_old_name = 4,
    renamed_new_name = 5,
}

---Represents a FileSystemWatcher at the specified path. Load using `local fsw = require("lstg.FileSystemWatcher")`
---@class lstg.FileSystemWatcher
---@field read fun(self:lstg.FileSystemWatcher, files_data:table<string, lstg.FileSystemWatcher.FileAction>) : boolean Fills the given table with data. Returns true if an even was read. Otherwise; false.
---@field close fun(self:lstg.FileSystemWatcher) Closes the fsw and destroys it.
---@field create fun(path:string) : lstg.FileSystemWatcher Creates a FileSystemWatcher instance.

---Represents a clipboard helper. Load using `local clipboard = require("lstg.Clipboard")`
---@class lstg.Clipboard
---@field hasText fun() : boolean Returns true if the clipboard contains text and isn't empty.
---@field getText fun() : string Gets the string currently existing in the clipboard.
---@field setText fun(string) Push a string into the clipboard.

---Represents the screens connected to the Graphics Card. Load using `local window = require("lstg.Display")`
---@class lstg.Display
---@field getAll fun() : table<lstg.Display>
---@field getPrimary fun() : lstg.Display
---@field getNearestFromWindow fun() : lstg.Display !! Will crash !! Not implemented in Sub.
---@field getFriendlyName fun(self:lstg.Display) : string Returns the friendly name of the monitor.
---@field getSize fun(self:lstg.Display) : lstg.Display.Size Returns the screen size.
---@field getPosition fun(self:lstg.Display) : lstg.Display.Position Returns the screen position in Windows.
---@field getRect fun(self:lstg.Display) : lstg.Display.Rect Returns the screen rect size.
---@field getWorkAreaSize fun(self:lstg.Display) : lstg.Display.Size Returns the work area of the screen.
---@field getWorkAreaPosition fun(self:lstg.Display) : lstg.Display.Position Returns the position of the work area of the screen.
---@field getWorkAreaRect fun(self:lstg.Display) : lstg.Display.Rect Returns the rect of the screen's work area.
---@field isPrimary fun(self:lstg.Display) : boolean Returns true if the screen is the primary screen in Windows. Otherwise; false.
---@field getDisplayScale fun(self:lstg.Display) : number Returns the scale of the screen display set in Windows.

---@class lstg.Display.Size
---@field width number
---@field height number

---@class lstg.Display.Position
---@field x number
---@field y number

---@class lstg.Display.Rect
---@field left number
---@field top number
---@field right number
---@field bottom number

---Represents the current game window.
---@class lstg.Window
---@field setTitle fun(title:string) Sets the window title.
---@field setWindowed fun(self:lstg.Window) Sets the window to windowed mode.
---@field setFullscreen fun(self:lstg.Window) Sets the window to exclusive fullscreen mode.
---@field setBorderless fun(self:lstg.Window) Sets the window to borderless fullscreen mode.

---Represents a Discord Rich Presence client.
---@class lstg.DiscordRPC
---@field Initialize fun(app_id:string) : boolean Initializes the RPC client with your own app id. Returns true on success.
---@field SetPresence fun(state:string, details:string, large_image_key:string, large_image_text:string, small_image_key:string, small_image_text:string, start_timestamp:number) : boolean Sets the current presence information. Returns true on success.
---@field ClearPresence fun() : boolean Clears the current presence information. Returns true on success.
---@field Shutdown fun() : boolean Shuts down the RPC client. Returns true on success.
---@field IsInitialized fun() : boolean Returns true if the RPC client is initialized. Otherwise; false.

---Represents a SQLite3 database connection. Load using `local sqlite3 = require("sqlite3")`
---
---Is a WIP (as of Flux v0.2.0)
---@class sqlite3
---@field open fun(path:string) : sqlite3 Opens a database connection at the specified path.
---@field exec fun(self:sqlite3, request:string) : boolean Executes a SQL query. Returns true on success.
---@field close fun(self:sqlite3) Closes the database connection.

---Represents a RichText instance.
---
---This text rendering supports the following tags:
---- [b]bold[/b]
---- [i]italic[/i]
---- [u]underline[/u]
---- [s]strikethrough[/s]
---- [color=#RRGGBB] or [color=#AARRGGBB] ... [/color]
---- [size=N]sized[/size]
---- [ruby=reading]base[/ruby]
---- [wave]text[/wave]
---- [wave amp=N speed=N]...[/wave]
---- [shake]text[/shake]
---- [shake i=N]...[/shake]
---- [gradient=#RRGGBB,#RRGGBB]text[/gradient] (also: [gradiant=...])
---@class lstg.RichText
---
---Constructors
---@field create fun(path:string, size:number) : lstg.RichText Creates a RichText object. `path` is relative to the game path. `size` is font size from units on screen.
---@field createFromSystem fun(name:string, size:number) : lstg.RichText Creates a RichText object from a system font. `name` is the friendly name of the system font. `size` is font size from units on screen.
---@field createFromPool fun(name:string, size:number) : lstg.RichText Creates a RichText object from a loaded font resource. `name` is the name of a TTF resource. `size` is font size from units on screen.
---
---Methods
---@field setText fun(self:lstg.RichText, text:string) Sets the text of the RichText object. Supports Rich Text tags. See documentation for supported tags.
---@field setFillColor fun(self:lstg.RichText, color:lstg.Color) Sets the fill color of the text. Will be overridden by inline color tags.
---@field setOutline fun(self:lstg.RichText, size:number, color:lstg.Color) Sets the outline color and size.
---@field setShadow fun(self:lstg.RichText, offsetX:number, offsetY:number, color:lstg.Color, blur:number?) Sets a drop shadow. `offsetX`/`offsetY` are the shadow offset in world units. `blur` is the Gaussian blur radius in pixels (default `0`).
---@field clearShadow fun(self:lstg.RichText) Removes the drop shadow.
---@field setFontSize fun(self:lstg.RichText, size:number) Changes the font size. Rebuilds the text format and layout.
---@field setTextWrap fun(self:lstg.RichText, width:number) Sets the word wrap width in world units. Put `0` to remove the limit (auto-size mode).
---@field setMaxWidth fun(self:lstg.RichText, width:number) Sets the max width of the text in world units. If the text doesn't fit, font size will shrink to fit. Put `0` to remove the limit.
---@field setMaxHeight fun(self:lstg.RichText, height:number) Sets the max height of the text in world units. If the text doesn't fit, font size will shrink to fit. Put `0` to remove the limit.
---@field setHAlign fun(self:lstg.RichText, align:"left"|"center"|"right") Sets horizontal text alignment. Default is `"left"`.
---@field setVAlign fun(self:lstg.RichText, align:"top"|"middle"|"bottom") Sets vertical text alignment. Default is `"top"`.
---@field setAlignment fun(self:lstg.RichText, h:"left"|"center"|"right"|nil, v:"top"|"middle"|"bottom"|nil) Sets horizontal and vertical alignment at once. Either argument may be `nil` to leave that axis unchanged.
---@field setUnitPerPixel fun(self:lstg.RichText, v:number) Sets how many world units correspond to one texture pixel. Disables auto-scale. You usually won't need to use this.
---@field getUnitPerPixel fun(self:lstg.RichText) : number Returns the current units-per-pixel ratio.
---@field setAutoScale fun(self:lstg.RichText, enable:boolean?) When `true`, `unitPerPixel` is automatically computed each frame from the canvas/viewport ratio. Calling `setUnitPerPixel` disables this. Defaults to true.
---@field update fun(self:lstg.RichText) Updates the RichText object. Should be called each frame.
---@field hasAnimation fun(self:lstg.RichText) : boolean Returns `true` if the current text contains animated tags (e.g. `[wave]`, `[shake]`). You may want to wrap `update` inside an if statement checking this.
---@field measure fun(self:lstg.RichText) : number, number Returns the rendered text dimensions in pixels as `width, height`, before any scale is applied.
---@field render fun(self:lstg.RichText, x:number, y:number, scaleX:number?, scaleY:number?, rotation:number?) Renders the text at world position `(x, y)`. `scaleX`/`scaleY` default to `1`. `rotation` is in degrees and defaults to `0`. The pivot point follows the current alignment setting.
---@field setState fun(self:lstg.RichText, blend:BlendMode, color:lstg.Color) Sets the render state for the text. Will be applied to all characters on top of what's already here.
---@field destroy fun(self:lstg.RichText) Destroys the RichText object and frees all resources used by it. Do not use the object after calling this.
---@operator len: integer Returns the number of characters in the plain text, excluding markup tags.
---@operator concat: string Concatenates the text of two RichText objects, returning a new one.
---@alias RichText lstg.RichText

---@class lstg.Renderer
---
---Model level
---@field setModelAmbient fun(name:string, r:number, g:number, b:number, brightness:number?) Sets the ambient color of a model resource. `Brightness` is [0, 1] (very sensitive).
---@field setModelDirectionalLight fun(name:string, dx:number, dy:number, dz:number, r:number, g:number, b:number, brightness:number?) Sets a directional light for a model resource. `Brightness` is [0, 1] (very sensitive).
---@field addModelPointLight fun(name:string, x:number, y:number, z:number, r:number, g:number, b:number, brightness:number?, range:number?) Adds a point light to a model resource. `Brightness` is [0, 1] (very sensitive). `Range` is the effective range of the light in world units.
---@field clearModelPointLights fun(name:string) Clears all point lights of a model resource.
---
---Scene level
---@field addScenePointLight fun(x:number, y:number, z:number, r:number, g:number, b:number, brightness:number?, range:number?) Adds a point light to the scene. `Brightness` is [0, 1] (very sensitive). `Range` is the effective range of the light in world units. Defaults to 1.0 and 10.0
---@field setScenePointLight fun(index:integer, x:number, y:number, z:number, r:number, g:number, b:number, brightness:number?, range:number?) Sets a point light in the scene. `index` is returned by `addScenePointLight`. `Brightness` is [0, 1] (very sensitive). `Range` is the effective range of the light in world units. Defaults to 1.0 and 10.0
---@field getScenePointLightCount fun() : integer Returns the current point lights in the scene. Max is 255.
---@field clearScenePointLights fun() Clears all point lights in the scene.

---------------------------------------

BoxCheck = lstg.BoxCheck
ColliCheck = lstg.ColliCheck
Angle = lstg.Angle
Dist = lstg.Dist
GetV = lstg.GetV
SetV = lstg.SetV
GetAttr = lstg.GetAttr
SetAttr = lstg.SetAttr
DefaultRenderFunc = lstg.DefaultRenderFunc
SetImgState = lstg.SetImgState
SetParState = lstg.SetParState
ParticleStop = lstg.ParticleStop
ParticleFire = lstg.ParticleFire
ParticleGetn = lstg.ParticleGetn
ParticleGetEmission = lstg.ParticleGetEmission
ParticleSetEmission = lstg.ParticleSetEmission
GetSuperPause = lstg.GetSuperPause
SetSuperPause = lstg.SetSuperPause
AddSuperPause = lstg.AddSuperPause
GetCurrentSuperPause = lstg.GetCurrentSuperPause
SetWorldFlag = lstg.SetWorldFlag
IsSameWorld = lstg.IsSameWorld
SetActiveWorlds = lstg.SetActiveWorlds
GetActiveWorlds = lstg.GetActiveWorlds
SetResLoadInfo = lstg.SetResLoadInfo
CreateResourcePool = lstg.CreateResourcePool
RemoveResourcePool = lstg.RemoveResourcePool
SetResourceStatus = lstg.SetResourceStatus
GetResourceStatus = lstg.GetResourceStatus
LoadTexture = lstg.LoadTexture
LoadImage = lstg.LoadImage
LoadAnimation = lstg.LoadAnimation
LoadPS = lstg.LoadPS
LoadSound = lstg.LoadSound
LoadMusic = lstg.LoadMusic
LoadFont = lstg.LoadFont
LoadTTF = lstg.LoadTTF
LoadFX = lstg.LoadFX
LoadModel = lstg.LoadModel
CreateRenderTarget = lstg.CreateRenderTarget
Color = lstg.Color
RemoveResource = lstg.RemoveResource
CheckRes = lstg.CheckRes
EnumRes = lstg.EnumRes
ParticleSystemData = lstg.ParticleSystemData
SetImageState = lstg.SetImageState
SetImageCenter = lstg.SetImageCenter
SetAnimationCenter = lstg.SetAnimationCenter
SetAnimationScale = lstg.SetAnimationScale
GetAnimationScale = lstg.GetAnimationScale
SetAnimationState = lstg.SetAnimationState
Render = lstg.Render
SetFontState = lstg.SetFontState
CacheTTFString = lstg.CacheTTFString
PlaySound = lstg.PlaySound
StopSound = lstg.StopSound
PauseSound = lstg.PauseSound
ResumeSound = lstg.ResumeSound
MeshData = lstg.MeshData
---@diagnostic disable lowercase-global
sin = lstg.sin
cos = lstg.cos
tan = lstg.tan
asin = lstg.asin
acos = lstg.acos
atan = lstg.atan
atan2 = lstg.atan2
---@diagnostic enable lowercase-global
SaveTexture = lstg.SaveTexture
BeginScene = lstg.BeginScene
EndScene = lstg.EndScene
RenderClear = lstg.RenderClear
SetViewport = lstg.SetViewport
SetScissorRect = lstg.SetScissorRect
SetOrtho = lstg.SetOrtho
SetPerspective = lstg.SetPerspective
Render4V = lstg.Render4V
RenderAnimation = lstg.RenderAnimation
RenderTexture = lstg.RenderTexture
RenderMesh = lstg.RenderMesh
RenderModel = lstg.RenderModel
SetFog = lstg.SetFog
SetZBufferEnable = lstg.SetZBufferEnable
ClearZBuffer = lstg.ClearZBuffer
PushRenderTarget = lstg.PushRenderTarget
PopRenderTarget = lstg.PopRenderTarget
PostEffect = lstg.PostEffect
SetTextureSamplerState = lstg.SetTextureSamplerState
GetVersionNumber = lstg.GetVersionNumber
GetVersionName = lstg.GetVersionName
SetWindowed = lstg.SetWindowed
SetFPS = lstg.SetFPS
GetFPS = lstg.GetFPS
SetVsync = lstg.SetVsync
SetResolution = lstg.SetResolution
Log = lstg.Log
SystemLog = lstg.SystemLog
Print = lstg.Print
DoFile = lstg.DoFile
LoadTextFile = lstg.LoadTextFile
ChangeVideoMode = lstg.ChangeVideoMode
EnumResolutions = lstg.EnumResolutions
EnumGPUs = lstg.EnumGPUs
GetMouseState = lstg.GetMouseState
GetMousePosition = lstg.GetMousePosition
GetMouseWheelDelta = lstg.GetMouseWheelDelta
GetLastKey = lstg.GetLastKey
AfterFrame = lstg.AfterFrame
New = lstg.New
CollisionCheck = lstg.CollisionCheck
Kill = lstg.Kill
Del = lstg.Del
IsValid = lstg.IsValid
BoundCheck = lstg.BoundCheck
Execute = lstg.Execute
FindFiles = lstg.FindFiles
ExtractRes = lstg.ExtractRes
UnloadPack = lstg.UnloadPack
LoadPack = lstg.LoadPack
MessageBox = lstg.MessageBox
SetBGMVolume = lstg.SetBGMVolume
GetMusicState = lstg.GetMusicState
ResumeMusic = lstg.ResumeMusic
PauseMusic = lstg.PauseMusic
StopMusic = lstg.StopMusic
PlayMusic = lstg.PlayMusic
SetSEVolume = lstg.SetSEVolume
GetSoundState = lstg.GetSoundState
GetImageScale = lstg.GetImageScale
SetImageScale = lstg.SetImageScale
GetTextureSize = lstg.GetTextureSize
IsRenderTarget = lstg.IsRenderTarget
RenderRect = lstg.RenderRect
Snapshot = lstg.Snapshot
RenderTTF = lstg.RenderTTF
RenderText = lstg.RenderText
RenderGroupCollider = lstg.RenderGroupCollider
DrawCollider = lstg.DrawCollider
GetKeyState = lstg.GetKeyState
GetnObj = lstg.GetnObj
ObjFrame = lstg.ObjFrame
ObjRender = lstg.ObjRender
SetBound = lstg.SetBound
GetBound = lstg.GetBound
UpdateXY = lstg.UpdateXY
ResetPool = lstg.ResetPool
ObjList = lstg.ObjList
GetWorldFlag = lstg.GetWorldFlag
SetTitle = lstg.SetTitle
SetSplash = lstg.SetSplash
BentLaserData = lstg.BentLaserData
Rand = lstg.Rand
StopWatch = lstg.StopWatch
GetLocalAppDataPath = lstg.GetLocalAppDataPath
GetRoamingAppDataPath = lstg.GetRoamingAppDataPath
PlayVideo = lstg.PlayVideo
PauseVideo = lstg.PauseVideo
ResumeVideo = lstg.ResumeVideo
StopVideo = lstg.StopVideo
SeekVideo = lstg.SeekVideo
SetVideoLoop = lstg.SetVideoLoop
SetVideoVolume = lstg.SetVideoVolume
RenderVideo = lstg.RenderVideo
RenderVideoRect = lstg.RenderVideoRect
RenderVideo4V = lstg.RenderVideo4V
GetVideoState = lstg.GetVideoState
GetVideoTime = lstg.GetVideoTime
GetVideoTotalTime = lstg.GetVideoTotalTime
GetVideoSize = lstg.GetVideoSize
GetVideoVolume = lstg.GetVideoVolume
CollectGroup = lstg.CollectGroup
RichText = lstg.RichText

-- Undocumented API, still in experimental
-- 未公开的 API，还处于实验状态

---@diagnostic disable undefined-field

GetSEVolume = lstg.GetSEVolume
SetSESpeed = lstg.SetSESpeed
GetSESpeed = lstg.GetSESpeed
NextObject = lstg.NextObject -- Internal/内部方法
ResetObject = lstg.ResetObject
SetBGMLoop = lstg.SetBGMLoop
GetBGMSpeed = lstg.GetBGMSpeed
SetBGMSpeed = lstg.SetBGMSpeed
GetBGMVolume = lstg.GetBGMVolume
GetMusicFFT = lstg.GetMusicFFT
SetTexturePreMulAlphaState = lstg.SetTexturePreMulAlphaState
ObjTable = lstg.ObjTable -- Internal/内部方法

-- Completely deprecated API, are empty function, undocumented.
-- 彻底废弃的 API，已经是空函数

IsInWorld = lstg.IsInWorld
GetCurrentObject = lstg.GetCurrentObject
UpdateSound = lstg.UpdateSound
PostEffectApply = lstg.PostEffectApply
PostEffectCapture = lstg.PostEffectCapture
ShowSplashWindow = lstg.ShowSplashWindow

---@diagnostic enable undefined-field