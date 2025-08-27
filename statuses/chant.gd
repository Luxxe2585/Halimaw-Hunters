extends Status

func get_tooltip() -> String:
	return tooltip % duration

func initialize_status(target: Node) -> void:
	# Nothing extra needed on apply
	pass

func apply_status(target: Node) -> void:
		if target is Player:
			var char_stats: CharacterStats = target.stats
			char_stats.mana = max(0, char_stats.mana - 1)
