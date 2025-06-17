class_name TrueStrengthStatus
extends Status

const STENGTH_STATUS = preload("res://statuses/strength.tres")

var stacks_per_turn := 2

func apply_status(target: Node) -> void:
	var status_effect := StatusEffect.new()
	var strength := STENGTH_STATUS.duplicate()
	strength.stacks = stacks_per_turn
	status_effect.status = strength
	status_effect.execute([target])
	
	status_applied.emit(self)
