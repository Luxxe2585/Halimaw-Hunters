class_name GiantStatus
extends Status

const DAMAGE_MULTIPLIER := 1.0

func initialize_status(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)
	
	var dmg_dealt_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "No dmg dealt modifier on %s" % target)
	
	var giant_value := dmg_dealt_modifier.get_value("giant")
	if not giant_value:
		giant_value = ModifierValue.create_new_modifier("giant", ModifierValue.Type.PERCENT_BASED)
		giant_value.percent_value = DAMAGE_MULTIPLIER
		dmg_dealt_modifier.add_new_value(giant_value)


	# Connect to card played signal
	if not Events.card_played.is_connected(_on_card_played):
		Events.card_played.connect(_on_card_played.bind(target))

func _on_card_played(card: Card, target: Node) -> void:
	if card.type == Card.Type.ATTACK and duration > 0:
		duration -= 1
		status_changed.emit()
		
		# Remove modifier when duration reaches 0
		if duration <= 0:
			var dmg_dealt_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
			if dmg_dealt_modifier:
				dmg_dealt_modifier.remove_value("giant")

func get_tooltip() -> String:
	return tooltip % duration
