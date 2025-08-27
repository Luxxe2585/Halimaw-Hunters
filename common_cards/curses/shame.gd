class_name ShameCurse
extends CurseCard

const FRAIL_STATUS = preload("res://statuses/frail.tres")


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var frail_status := FRAIL_STATUS.duplicate()
	frail_status.duration = 1
	status_effect.status = frail_status
	status_effect.execute(targets)
