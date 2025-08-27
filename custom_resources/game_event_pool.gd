class_name GameEventPool
extends Resource

@export var events: Array[GameEvent]

func get_random_event() -> GameEvent:
	if events.is_empty():
		return null
	return events.pop_at(randi_range(0, events.size() - 1))
