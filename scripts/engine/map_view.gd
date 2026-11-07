class_name MapView
extends Node2D
## Draws the map: white background, the artwork layers and a pulsing ring at the current station.
## Layers with "above_gas" are drawn by a second MapView (setup with above_gas = true) placed over
## the gas dots, so the label lines and boxes stay on top.
## Moving layers (lungs, diaphragm) are drawn with system.layer_transform(motion, breath).
## No station dots: the artwork's pointer dots already mark each stop.
## Map-local space == screen. Knows only SimSystem.

const COL_HIGHLIGHT: Color = Color("#e8641b")
## Height of the rows a "rows" layer is drawn in (map px).
const ROW_HEIGHT: float = 3.0

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


## Draws a layer as thin horizontal rows, each widened about its own centre
## (system.layer_row_scale), so e.g. the chest can widen while the head stays put.
func _draw_rows(tex: Texture2D, layer: Dictionary) -> void:
	var rect: Rect2 = layer["rect"]
	var motion: String = str(layer["motion"])
	var tex_size: Vector2 = tex.get_size()
	var px_per_unit: float = tex_size.y / rect.size.y
	var y: float = 0.0
	while y < rect.size.y:
		var h: float = minf(ROW_HEIGHT, rect.size.y - y)
		var row: Vector2 = _system.layer_row_scale(motion, _breath, rect.position.y + y + h * 0.5)
		var x0: float = row.x + (rect.position.x - row.x) * row.y
		var dst: Rect2 = Rect2(x0, rect.position.y + y, rect.size.x * row.y, h)
		var src: Rect2 = Rect2(0.0, y * px_per_unit, tex_size.x, h * px_per_unit)
		draw_texture_rect_region(tex, dst, src)
		y += h


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
		if bool(layer.get("rows", false)):
			draw_set_transform_matrix(Transform2D.IDENTITY)
			_draw_rows(tex, layer)
			continue
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
