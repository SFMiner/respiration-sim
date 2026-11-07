class_name AirPuffToken
extends SimToken
## Quiz part 1 traveller: a small puff of oxygen dots that moves stop to stop along the airway.
## At the last stop (bronchioles) the dots scatter into the bronchioles and shrink to nothing,
## the same way the oxygen does in explore mode.

const PUFF_COUNT: int = 10
const PUFF_RADIUS: float = 9.0
const SINK_TIME: float = 1.0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _dots: Array[Dictionary] = []
var _time: float = 0.0
## 0..1 while sinking into the bronchioles at the end; -1 otherwise.
var _sink: float = -1.0


func _ready() -> void:
	_rng.randomize()
	reset_token()


func reset_token() -> void:
	_dots.clear()
	for i: int in PUFF_COUNT:
		var angle: float = TAU * float(i) / float(PUFF_COUNT) + _rng.randf_range(-0.3, 0.3)
		_dots.append({
			"home": Vector2.from_angle(angle) * _rng.randf_range(2.0, PUFF_RADIUS),
			"phase": _rng.randf_range(0.0, TAU),
			"freq": _rng.randf_range(3.0, 6.0),
			"radius": GasCloud.DOT_RADIUS * _rng.randf_range(0.85, 1.15),
			"target": Vector2.ZERO,
		})
	_sink = -1.0
	visible = true
	set_process(true)
	queue_redraw()


func on_arrive(index: int) -> float:
	if index != RespiratorySystem.BRONCHIOLES:
		return 0.3
	# Scatter into the nearest bronchiole branches (targets are relative to the token).
	var pts: Array[Vector2] = RespiratorySystem.BRONCHIOLE_POINTS
	for dot: Dictionary in _dots:
		var best: Vector2 = pts[_rng.randi() % pts.size()]
		for i: int in 3:
			var p: Vector2 = pts[_rng.randi() % pts.size()]
			if p.distance_squared_to(position) < best.distance_squared_to(position):
				best = p
		dot["target"] = best - position
	_sink = 0.0
	return SINK_TIME + 0.2


func _process(delta: float) -> void:
	_time += delta
	if _sink >= 0.0 and _sink < 1.0:
		_sink = minf(_sink + delta / SINK_TIME, 1.0)
	queue_redraw()


func _draw() -> void:
	for dot: Dictionary in _dots:
		var home: Vector2 = dot["home"]
		var wob: Vector2 = Vector2(sin(float(dot["phase"]) + _time * float(dot["freq"])), cos(float(dot["phase"]) * 1.7 + _time * float(dot["freq"]) * 0.8)) * 1.8
		var pos: Vector2 = home + wob
		var radius: float = float(dot["radius"])
		if _sink >= 0.0:
			var e: float = _sink * _sink * (3.0 - 2.0 * _sink)
			pos = pos.lerp(dot["target"], e)
			radius *= 1.0 - _sink
		if radius < 0.3:
			continue
		draw_circle(pos, radius + GasCloud.RIM_WIDTH, GasCloud.COL_RIM, true, -1.0, true)
		draw_circle(pos, radius, GasCloud.COL_OXYGEN, true, -1.0, true)
