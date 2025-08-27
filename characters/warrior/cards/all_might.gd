# all_might_card.gd
extends Card

@export var base_damage := 14


func get_default_tooltip() -> String:
	return tooltip_text % base_damage


func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var dmg_dealt_modifier = player_modifiers.get_modifier(Modifier.Type.DMG_DEALT)
	var modified_damage = _calculate_damage_with_triple_strength(base_damage, dmg_dealt_modifier)
	
	if enemy_modifiers:
		modified_damage = enemy_modifiers.get_modified_value(modified_damage, Modifier.Type.DMG_TAKEN)
		
	return tooltip_text % modified_damage


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	for target in targets:
		if target is Enemy:
			var dmg_dealt_modifier = modifiers.get_modifier(Modifier.Type.DMG_DEALT)
			var final_damage = _calculate_damage_with_triple_strength(base_damage, dmg_dealt_modifier)
			
			var damage_effect := DamageEffect.new()
			damage_effect.amount = final_damage
			damage_effect.sound = sound
			damage_effect.execute([target])


func _calculate_damage_with_triple_strength(base: int, dmg_dealt_modifier: Modifier) -> int:
	if not dmg_dealt_modifier:
		return base
	
	# Replicate the modifier calculation but apply strength three times
	var flat_result: int = base
	var percent_result: float = 1.0
	
	# Apply all flat modifiers first
	for value: ModifierValue in dmg_dealt_modifier.get_children():
		if value.type == ModifierValue.Type.FLAT:
			# If this is the strength modifier, apply it three times
			if value.source == "strength":
				flat_result += value.flat_value * 3
			else:
				flat_result += value.flat_value
	
	# Apply % modifiers next
	for value: ModifierValue in dmg_dealt_modifier.get_children():
		if value.type == ModifierValue.Type.PERCENT_BASED:
			percent_result += value.percent_value
	
	return floori(flat_result * percent_result)
