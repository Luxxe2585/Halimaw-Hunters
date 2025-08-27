# iron_blooded_card.gd
extends Card


func get_default_tooltip() -> String:
	return tooltip_text


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	for target in targets:
		if target is Player:
			var status_handler = target.status_handler
			var regen_status = status_handler._get_status("regen")
			
			if regen_status:
				var block_effect := BlockEffect.new()
				block_effect.amount = regen_status.duration
				block_effect.sound = sound
				block_effect.execute([target])
				
				# Halve regen stacks
				regen_status.stacks = max(1, regen_status.stacks / 2)
				regen_status.status_changed.emit()
