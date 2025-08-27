class_name DoubtCurse
extends CurseCard

const WEAK_STATUS = preload("res://statuses/weak.tres")


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var weak_status := WEAK_STATUS.duplicate()
	weak_status.duration = 1
	status_effect.status = weak_status
	status_effect.execute(targets)
