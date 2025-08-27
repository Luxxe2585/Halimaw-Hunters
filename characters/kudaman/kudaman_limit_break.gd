# limit_break_card.gd
extends Card



func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	for target in targets:
		if target is Player:
			var status_handler = target.status_handler
			var strength_status = status_handler._get_status("strength")
			
			if strength_status:
				# Double the strength stacks
				strength_status.stacks *= 2
				strength_status.status_changed.emit()
