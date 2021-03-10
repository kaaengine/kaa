Changelog
---------

0.11 (2021-03-10)
+++++++++++++++++

* Changed default time unit across the engine from milliseconds (`int`) to seconds (`float`) [API change].
* Timers redesign [API change].
* Added new property `Node.root_distance`
* Added new properties `Node.effective_z_index`, `Node.effective_views`
* Added new module `kaa.statistics`
* Added new utility `kaa.tools.stats_graph`
* Added `InputManager.cursor_visible` property.
* Added `BoundingBox.intersection` method.
* Added `Engine.get_fps` function.
* Added `Scene.time_scale` property.
* Added `Node.on_attach` and `Node.on_detach` customizable methods.
* Added `Node.__bool__`.
* Added extra checks for unsafe (e.g. deleted) nodes access.
* Added internal statistics manager with exporter over `UDP/IP`.
* Fixed bug with incorrect operations order when using `Transformation`s.
* Fixed font rendering with HLSL shader.
* Fixed log module reporting on Windows.
* Fixed rare hangups during engine shutdown.
* Added CHANGELOG.
