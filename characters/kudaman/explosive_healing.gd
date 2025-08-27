# explosive_healing_card.gd
extends Card


func get_default_tooltip() -> String:
	return tooltip_text


func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	for target in targets:
			var player = target.get_tree().get_first_node_in_group("player") as Player
			var status_handler = player.status_handler
			var regen_status = status_handler._get_status("regen")
			
			if regen_status:
				var damage_effect := DamageEffect.new()
				damage_effect.amount = regen_status.duration
				damage_effect.sound = sound
				damage_effect.execute(targets)
