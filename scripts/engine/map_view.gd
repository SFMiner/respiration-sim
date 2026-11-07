class_name MapView
extends Node2D
## Draws the map: white background, the artwork layers and a pulsing ring at the current station.
## Layers with "above_gas" are drawn by a second MapView (setup with above_gas = true) placed over
## the gas dots, so the label lines and boxes stay on top.
## Moving layers (lungs, diaphragm) are drawn with system.layer_transform(motion, breath).
## No station dots: the artwork's pointer dots already mark each stop.
## Map-local space == screen. Knows only SimSystem.

const COL_HIGHLIGHT: Color = Color("#e8641b")

var _system: SimSystem
var _above_gas: bool = false
var _textures: Array[Texture2D] = []
var _layers: Array[Dictionary] = []
var _highlight: int = -1
var _pulse: float = 0.0
var _breath: float = 0.0


func setup(sys: SimSystem, above_gas: bool = false) -> void:
	_system = sys
	_above_gas = above_gas
	_layers.clear()
	_textures.clear()
	for layer: Dictionary in sys.layers:
		if bool(layer["above_gas"]) != above_gas:
			continue
		_layers.append(layer)
		_textures.append(load(str(layer["path"])) as Texture2D)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_process(false)
	queue_redraw()


## 0 = breathed out, 1 = breathed in. Moves the lungs and diaphragm.
func set_breath(value: float) -> void:
	if is_equal_approx(value, _breath):
		return
	_breath = value
	queue_redraw()


## -1 = none. Otherwise a pulsing ring is drawn around that station.
func set_highlight(index: int) -> void:
	if _system == null or _above_gas or index < 0 or index >= _system.station_count():
		_highlight = -1
	else:
		_highlight = index
	_pulse = 0.0
	set_process(_highlight >= 0)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse += delta
	queue_redraw()


func _draw() -> void:
	if _system == null:
		return
	if not _above_gas:
		draw_rect(Rect2(Vector2.ZERO, _system.map_size), Color.WHITE)
	for i: int in _layers.size():
		var tex: Texture2D = _textures[i]
		if tex == null:
			continue
		var layer: Dictionary = _layers[i]
		draw_set_transform_matrix(_system.layer_transform(str(layer["motion"]), _breath))
		draw_texture_rect(tex, layer["rect"], false)
	draw_set_transform_matrix(Transform2D.IDENTITY)
	if _highlight >= 0:
		var hp: Vector2 = _system.station_pos(_highlight)
		var wave: float = 0.5 + 0.5 * sin(_pulse * 6.0)
		var ring_r: float = 17.0 + 4.0 * wave
		draw_arc(hp, ring_r + 5.0, 0.0, TAU, 48, Color(COL_HIGHLIGHT.r, COL_HIGHLIGHT.g, COL_HIGHLIGHT.b, 0.35 * (1.0 - wave)), 4.0, true)
		# White edge so the orange ring still shows on pink and orange tissue.
		draw_arc(hp, ring_r, 0.0, TAU, 48, Color.WHITE, 8.0, true)
		draw_arc(hp, ring_r, 0.0, TAU, 48, COL_HIGHLIGHT, 4.0, true)
