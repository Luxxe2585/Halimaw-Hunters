class_name IntuitionStatus
extends Status

var health_loss_blocked := false


func should_block_damage(damage: int, current_block: int) -> bool:
	# Only block if damage would exceed current block and we have stacks available
	return stacks > 0 and not health_loss_blocked and damage > current_block

func block_damage() -> void:
	if stacks > 0 and not health_loss_blocked:
		health_loss_blocked = true
		stacks -= 1
		status_changed.emit()
		
		if stacks > 0:
			health_loss_blocked = false

func get_tooltip() -> String:
	return tooltip % stacks
