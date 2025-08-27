class_name WeakStatus
extends Status

const DAMAGE_REDUCTION := 0.25

func get_tooltip() -> String:
	return tooltip % duration

func initialize_status(target: Node) -> void:
	assert(target.get("modifier_handler"), "No modifiers on %s" % target)

	var dmg_dealt_modifier: Modifier = target.modifier_handler.get_modifier(Modifier.Type.DMG_DEALT)
	assert(dmg_dealt_modifier, "No dmg dealt modifier on %s" % target)

	var weak_value := dmg_dealt_modifier.get_value("weak")
	if not weak_value:
		weak_value = ModifierValue.create_new_modifier("weak", ModifierValue.Type.PERCENT_BASED)
		dmg_dealt_modifier.add_new_value(weak_value)

	weak_value.percent_value = -DAMAGE_REDUCTION

	if not status_changed.is_connected(_on_status_changed):
		status_changed.connect(_on_status_changed.bind(dmg_dealt_modifier))

func _on_status_changed(dmg_dealt_modifier: Modifier) -> void:
	if duration <= 0:
		dmg_dealt_modifier.remove_value("weak")
