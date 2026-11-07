class_name GasCloud
extends Node2D
## The gas dots of one breath, drawn in map-local space.
## Inhale: bright green oxygen dots come in at the nostril, follow the airflow path with a loose
## sideways wobble (so they look like a cloud, not a column), leave the path at random places in
## the cut-open lung and shrink to nothing as they sink into the bronchioles.
## Exhale: bright purple carbon dioxide dots do the exact reverse: they grow out of the
## bronchioles, join the path and wobble back up and out of the nose.
## Dots inside the cut-open lung move with it as it grows (system.layer_transform "left_lung").

enum Kind { OXYGEN, CARBON_DIOXIDE }
enum Mode { NONE, INHALE, EXHALE }
enum DotState { WAITING, ON_PATH, IN_LUNG, DONE }

const COL_OXYGEN: Color = Color("#1fe05a")
const COL_CARBON_DIOXIDE: Color = Color("#b43cff")
const COL_RIM: Color = Color(0.1, 0.08, 0.16, 0.9)
const DOT_COUNT: int = 36
const DOT_RADIUS: float = 4.0
const RIM_WIDTH: float = 1.4
## Dots start / finish this far outside the nostril, fading in / out.
const OUTSIDE: float = 30.0
## Seconds a dot takes to sink into (or rise out of) a bronchiole.
const LUNG_TIME: float = 0.7
## Sideways spread around the path (map px).
const SIDE_SPREAD: float = 4.5
const WOBBLE_MIN: float = 1.5
const WOBBLE_MAX: float = 3.5

var mode: Mode = Mode.NONE

var _system: RespiratorySystem
var _dots: Array[Dictionary] = []
var _breath: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func setup(sys: RespiratorySystem) -> void:
	_system = sys
	_rng.randomize()


func clear() -> void:
	_dots.clear()
	mode = Mode.NONE
	queue_redraw()


func is_active() -> bool:
	for dot: Dictionary in _dots:
		if int(dot["state"]) != DotState.DONE:
			return true
	return false


## Oxygen in. `duration` = length of the inhale in sim seconds; most dots are in by its end.
func start_inhale(duration: float) -> void:
	_drop_finished()
	mode = Mode.INHALE
	var lung_from: float = _system.distance_at_index(RespiratorySystem.LUNG_BLEND_TO) + 6.0
	var lung_to: float = _system.path_length() - 2.0
	for i: int in DOT_COUNT:
		var dot: Dictionary = _new_dot(Kind.OXYGEN)
		var delay: float = duration * 0.3 * float(i) / float(DOT_COUNT - 1) + _rng.randf_range(0.0, 0.08)
		var exit_d: float = _rng.randf_range(lung_from, lung_to)
		var travel: float = maxf(duration * 0.85 - delay - LUNG_TIME, 0.6)
		dot["delay"] = delay
		dot["d"] = -OUTSIDE
		dot["exit_d"] = exit_d
		dot["v"] = (exit_d + OUTSIDE) / travel * _rng.randf_range(0.92, 1.08)
		dot["target"] = _pick_target(_rest_path_pos(dot, exit_d))
		_dots.append(dot)
	queue_redraw()


## Carbon dioxide out. `duration` = length of the exhale in sim seconds.
func start_exhale(duration: float) -> void:
	_drop_finished()
	mode = Mode.EXHALE
	var lung_from: float = _system.distance_at_index(RespiratorySystem.LUNG_BLEND_TO) + 6.0
	var lung_to: float = _system.path_length() - 2.0
	for i: int in DOT_COUNT:
		var dot: Dictionary = _new_dot(Kind.CARBON_DIOXIDE)
		var delay: float = duration * 0.25 * float(i) / float(DOT_COUNT - 1) + _rng.randf_range(0.0, 0.08)
		var exit_d: float = _rng.randf_range(lung_from, lung_to)
		var travel: float = maxf(duration * 0.9 - delay - LUNG_TIME, 0.6)
		dot["delay"] = delay
		dot["d"] = exit_d
		dot["exit_d"] = exit_d
		dot["v"] = (exit_d + OUTSIDE) / travel * _rng.randf_range(0.92, 1.08)
		dot["target"] = _pick_target(_rest_path_pos(dot, exit_d))
		_dots.append(dot)
	queue_redraw()


## How far along the path the leading air has got (map px from the nostril).
## Inhale: the furthest oxygen dot. Exhale: the carbon dioxide dot nearest the nose
## (path length before any have left the lung, below 0 once all are out).
func front_distance() -> float:
	match mode:
		Mode.INHALE:
			var best: float = -OUTSIDE
			for dot: Dictionary in _dots:
				if int(dot["kind"]) != Kind.OXYGEN:
					continue
				var st: int = int(dot["state"])
				if st == DotState.ON_PATH:
					best = maxf(best, float(dot["d"]))
				elif st == DotState.IN_LUNG or st == DotState.DONE:
					best = maxf(best, float(dot["exit_d"]))
			return best
		Mode.EXHALE:
			var lowest: float = _system.path_length()
			var all_out: bool = true
			for dot: Dictionary in _dots:
				if int(dot["kind"]) != Kind.CARBON_DIOXIDE:
					continue
				var st: int = int(dot["state"])
				if st == DotState.ON_PATH:
					lowest = minf(lowest, float(dot["d"]))
				if st != DotState.DONE:
					all_out = false
			return -OUTSIDE if all_out else lowest
	return -OUTSIDE


## `delta` is already scaled by the sim speed. `breath` = current lung expansion (0..1).
func advance(delta: float, breath: float) -> void:
	_breath = breath
	if _dots.is_empty():
		return
	for dot: Dictionary in _dots:
		dot["age"] = float(dot["age"]) + delta
		match int(dot["state"]):
			DotState.WAITING:
				dot["delay"] = float(dot["delay"]) - delta
				if float(dot["delay"]) <= 0.0:
					dot["state"] = DotState.ON_PATH if int(dot["kind"]) == Kind.OXYGEN else DotState.IN_LUNG
			DotState.ON_PATH:
				if int(dot["kind"]) == Kind.OXYGEN:
					dot["d"] = float(dot["d"]) + float(dot["v"]) * delta
					if float(dot["d"]) >= float(dot["exit_d"]):
						dot["d"] = dot["exit_d"]
						dot["from"] = _rest_path_pos(dot, float(dot["exit_d"]))
						dot["u"] = 0.0
						dot["state"] = DotState.IN_LUNG
				else:
					dot["d"] = float(dot["d"]) - float(dot["v"]) * delta
					if float(dot["d"]) <= -OUTSIDE:
						dot["state"] = DotState.DONE
			DotState.IN_LUNG:
				dot["u"] = float(dot["u"]) + delta / LUNG_TIME
				if float(dot["u"]) >= 1.0:
					if int(dot["kind"]) == Kind.OXYGEN:
						dot["state"] = DotState.DONE
					else:
						dot["state"] = DotState.ON_PATH
	queue_redraw()


## Keeps dots of the last breath that are still moving (oxygen still sinking in, say),
## so starting the next breath early doesn't make them vanish.
func _drop_finished() -> void:
	var keep: Array[Dictionary] = []
	for dot: Dictionary in _dots:
		if int(dot["state"]) != DotState.DONE:
			keep.append(dot)
	_dots = keep


func _new_dot(kind: Kind) -> Dictionary:
	return {
		"kind": kind,
		"state": DotState.WAITING,
		"delay": 0.0,
		"age": 0.0,
		"d": 0.0,
		"v": 0.0,
		"exit_d": 0.0,
		"u": 0.0,
		"side": _rng.randf_range(-SIDE_SPREAD, SIDE_SPREAD),
		"wob_amp": _rng.randf_range(WOBBLE_MIN, WOBBLE_MAX),
		"wob_freq": _rng.randf_range(3.0, 6.5),
		"wob_phase": _rng.randf_range(0.0, TAU),
		"radius": DOT_RADIUS * _rng.randf_range(0.85, 1.15),
		"from": Vector2.ZERO,
		"target": Vector2.ZERO,
	}


## Sideways offset from the path for this dot right now.
func _offset(dot: Dictionary) -> float:
	return float(dot["side"]) + float(dot["wob_amp"]) * sin(float(dot["wob_phase"]) + float(dot["age"]) * float(dot["wob_freq"]))


## Position on the path at distance `d` with the dot's sideways offset, before any lung movement.
func _rest_path_pos(dot: Dictionary, d: float) -> Vector2:
	return _system.point_at(d) + _system.normal_at(d) * _offset(dot)


## A bronchiole point near `from`: the closest of a few random ones, so dots scatter
## into the nearby branches rather than flying across the lung.
func _pick_target(from: Vector2) -> Vector2:
	var pts: Array[Vector2] = RespiratorySystem.BRONCHIOLE_POINTS
	var best: Vector2 = pts[_rng.randi() % pts.size()]
	for i: int in 3:
		var p: Vector2 = pts[_rng.randi() % pts.size()]
		if p.distance_squared_to(from) < best.distance_squared_to(from):
			best = p
	return best


func _draw() -> void:
	if _system == null:
		return
	var lung: Transform2D = _system.layer_transform("left_lung", _breath)
	for dot: Dictionary in _dots:
		var st: int = int(dot["state"])
		if st == DotState.WAITING or st == DotState.DONE:
			continue
		var pos: Vector2
		var radius: float = float(dot["radius"])
		var alpha: float = 1.0
		var oxygen: bool = int(dot["kind"]) == Kind.OXYGEN
		if st == DotState.ON_PATH:
			var d: float = float(dot["d"])
			var rest: Vector2 = _rest_path_pos(dot, d)
			pos = rest.lerp(lung * rest, _system.lung_weight(d))
			alpha = clampf(1.0 + d / OUTSIDE, 0.0, 1.0)
		else:
			var u: float = clampf(float(dot["u"]), 0.0, 1.0)
			var eased: float = u * u * (3.0 - 2.0 * u)
			var path_end: Vector2 = dot["from"] if oxygen else _rest_path_pos(dot, float(dot["exit_d"]))
			var bronchiole: Vector2 = dot["target"]
			var rest_pos: Vector2 = path_end.lerp(bronchiole, eased) if oxygen else bronchiole.lerp(path_end, eased)
			pos = lung * rest_pos
			# Oxygen shrinks to nothing as it sinks in; carbon dioxide grows as it comes out.
			radius *= (1.0 - u) if oxygen else u
		if radius < 0.3 or alpha <= 0.0:
			continue
		var col: Color = COL_OXYGEN if oxygen else COL_CARBON_DIOXIDE
		col.a = alpha
		var rim: Color = COL_RIM
		rim.a *= alpha
		draw_circle(pos, radius + RIM_WIDTH, rim, true, -1.0, true)
		draw_circle(pos, radius, col, true, -1.0, true)
