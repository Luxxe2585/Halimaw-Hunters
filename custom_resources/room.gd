class_name Room
extends Resource

enum Type {NOT_ASSIGNED, MONSTER, TREASURE, CAMPFIRE, SHOP, BOSS, ELITE, QUIZ_EVENT}

@export var type: Type
@export var row: int
@export var column: int
@export var position: Vector2
@export var next_rooms: Array[Room]
@export var selected := false
#only used by MONSTER, ELITE, and BOSS room types
@export var battle_stats: BattleStats


func _to_string() -> String:
	return "%s (%s)" % [column, Type.keys()[type]]
