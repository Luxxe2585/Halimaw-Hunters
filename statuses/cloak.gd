class_name CloakStatus
extends Status

const REGEN_STATUS = preload("res://statuses/regen.tres")

func get_tooltip() -> String:
	return tooltip % stacks

func apply_status(target: Node) -> void:
	var regen := REGEN_STATUS.duplicate()
	regen.duration = stacks
	var effect := StatusEffect.new()
	effect.status = regen
	effect.execute([target])

	status_applied.emit(self)
