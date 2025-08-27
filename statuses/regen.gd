class_name RegenStatus
extends Status

func apply_status(target: Node) -> void:
	if duration > 0:
		var heal_effect := HealEffect.new()
		heal_effect.amount = duration
		heal_effect.execute([target])

	status_applied.emit(self)

func get_tooltip() -> String:
	return tooltip % duration
