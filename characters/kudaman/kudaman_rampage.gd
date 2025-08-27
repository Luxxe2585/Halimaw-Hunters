extends Card

var base_damage := 3
var hit_count := 4


func get_default_tooltip() -> String:
	return tooltip_text % base_damage


func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var modified_dmg := player_modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	
	if enemy_modifiers:
		modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
		
	return tooltip_text % modified_dmg


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	for target in targets:
		var tree = target.get_tree()
		var tween = tree.create_tween()
	
		for i in range(hit_count):
			tween.tween_callback(deal_damage.bind(targets, modifiers))
			tween.tween_interval(0.25)  # 0.25s delay between attacks


func deal_damage(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	damage_effect.sound = sound
	damage_effect.execute(targets)
