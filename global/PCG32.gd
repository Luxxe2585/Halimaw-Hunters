class_name PCG32_manual
extends Node

const MULTIPLIER: int = 6364136223846793005
const INCREMENT: int = 1442695040888963407
const PI: float = 3.14159265358979323846

var _state: int = 0

# Properties: seed and state
var seed: int:
	set(value):
		_state = value * MULTIPLIER + INCREMENT
	get:
		return _state

var state: int:
	set(value):
		_state = value
	get:
		return _state

func _init() -> void:
	pass  # Default state is 0; call randomize() for time-based initialization

# Generates the next 32-bit pseudo-random number
func _next_int() -> int:
	var old_state: int = _state
	_state = old_state * MULTIPLIER + INCREMENT
	var xorshifted: int = ((old_state >> 18) ^ old_state) >> 27
	var rot: int = (old_state >> 59) & 0x1F
	var result: int = (xorshifted >> rot) | (xorshifted << ((-rot) & 31))
	return result & 0xFFFFFFFF  # Ensure 32-bit unsigned


func randomize() -> void:
	var time: int = Time.get_ticks_usec()
	var id: String = OS.get_unique_id()
	var new_seed: int = time ^ id.hash()
	self.seed = new_seed

func randi() -> int:
	return _next_int()

func randi_range(from: int, to: int) -> int:
	if from > to:
		var temp: int = from
		from = to
		to = temp
	
	var range_val: int = to - from + 1
	if range_val <= 0:
		return from
	
	var threshold: int = (4294967296 - range_val) % range_val
	while true:
		var r: int = _next_int()
		if r >= threshold:
			return from + (r % range_val)

	return from

func randf() -> float:
	return float(_next_int()) / 4294967295.0  # 2^32 - 1

func randf_range(from: float, to: float) -> float:
	return from + (to - from) * randf()

func randfn(mean: float = 0.0, deviation: float = 1.0) -> float:
	var u1: float = randf()
	var u2: float = randf()
	var z0: float = cos(2.0 * PI * u1) * sqrt(-2.0 * log(u2))
	return mean + deviation * z0

func rand_weighted(weights: PackedFloat32Array) -> int:
	if weights.size() == 0:
		push_error("Weight array is empty")
		return -1
	
	var total: float = 0.0
	for w in weights:
		total += w
	
	var r: float = randf() * total
	var accum: float = 0.0
	for i in weights.size():
		accum += weights[i]
		if r < accum:
			return i
	
	return weights.size() - 1
