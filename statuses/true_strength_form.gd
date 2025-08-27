class_name TrueStrengthStatus
extends Status

const STENGTH_STATUS = preload("res://statuses/strength.tres")


func apply_status(target: Node) -> void:
	var status_effect := StatusEffect.new()
	var strength := STENGTH_STATUS.duplicate()
	strength.stacks = stacks
	status_effect.status = strength
	status_effect.execute([target])
	
	status_applied.emit(self)

func get_tooltip() -> String:
	return tooltip % stacks
