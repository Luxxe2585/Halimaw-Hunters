class_name DefenseStatus
extends Status

func get_tooltip() -> String:
	return tooltip % stacks

func initialize_status(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)

	var block_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.BLOCK_GAINED)
	assert(block_modifier, "No block modifier on %s" % target)

	var defense_value := block_modifier.get_value("defense")
	if not defense_value:
		defense_value = ModifierValue.create_new_modifier("defense", ModifierValue.Type.FLAT)
		block_modifier.add_new_value(defense_value)

	defense_value.flat_value = stacks

	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(block_modifier))

func _on_status_changed(block_modifier: Modifier) -> void:
	if duration <= 0:
		block_modifier.remove_value("defense")
