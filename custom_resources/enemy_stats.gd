class_name  EnemyStats
extends Stats

@export var ai: PackedScene

var is_readied := false:
	set(value):
		is_readied = value
		stats_changed.emit()

var sequence_order := 1:
	set(value):
		sequence_order = value
		stats_changed.emit()
