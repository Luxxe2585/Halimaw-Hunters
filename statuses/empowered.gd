class_name EmpoweredStatus
extends Status

const BONUS := 0.5

func initialize_status(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)

	var dmg_dealt_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "No dmg dealt modifier on %s" % target)

	var empowered_value := dmg_dealt_modifier.get_value("empowered")
	if not empowered_value:
		empowered_value = ModifierValue.create_new_modifier("empowered", ModifierValue.Type.PERCENT_BASED)
		empowered_value.percent_value = BONUS
		dmg_dealt_modifier.add_new_value(empowered_value)


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
				dmg_dealt_modifier.remove_value("empowered")

func get_tooltip() -> String:
	return tooltip % duration
