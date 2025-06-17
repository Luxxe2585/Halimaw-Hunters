extends Node

var instance: PCG32_manual


func _ready() -> void:
	initialize()


func initialize() -> void:
	instance = PCG32_manual.new()
	instance.randomize()


func set_from_save_data(which_seed: int, state: int) -> void:
	instance = PCG32_manual.new()
	instance.seed = which_seed
	instance.state = state


func array_pick_random(array: Array) -> Variant:
	if array.is_empty():
		return null

	return array[instance.randi() % array.size()]


func array_shuffle(array: Array) -> void:
	if array.size() < 2:
		return

	for i in range(array.size()-1, 0, -1):
		var j := instance.randi() % (i + 1)
		var tmp = array[j]
		array[j] = array[i]
		array[i] = tmp
