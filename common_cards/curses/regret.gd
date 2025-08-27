class_name RegretCurse
extends CurseCard


func get_default_tooltip() -> String:
	return tooltip_text


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in targets:
		if target is Player:
			var hand_size = target.hand.get_child_count()
			target.stats.health -= hand_size
			target.stats.stats_changed.emit()
