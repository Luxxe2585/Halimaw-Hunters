extends Card

var base_damage := 18
var heal_amount := 20


func get_default_tooltip() -> String:
	return tooltip_text % [base_damage, heal_amount]


func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var modified_damage := player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	
	if enemy_modifiers:
		modified_damage = enemy_modifiers.get_modified_value(modified_damage, Modifier.Type.DMG_TAKEN)
		
	return tooltip_text % [modified_damage, heal_amount]


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	# Heal player
	var tree := targets[0].get_tree()
	var players = tree.get_nodes_in_group("player")
	if players.size() > 0:
		var heal_effect := HealEffect.new()
		heal_effect.amount = heal_amount
		heal_effect.execute([players[0]])
