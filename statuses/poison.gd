class_name PoisonStatus
extends Status

func apply_status(target: Node) -> void:
	if duration > 0:
		var damage_effect := DamageEffect.new()
		damage_effect.amount = duration
		damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER
		damage_effect.execute([target])
		duration -= 1
	
	status_applied.emit(self)

func get_tooltip() -> String:
	return tooltip % stacks
