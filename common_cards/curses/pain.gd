extends CurseCard



func get_default_tooltip() -> String:
	return tooltip_text

func get_updated_tooltip(_player_modifiers: ModifierHandler, _enemy_modifiers: ModifierHandler) -> String:
	return tooltip_text

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	# Pain doesn't have an effect when "played" since it's unplayable
	# Its effect is handled in the PlayerHandler's _on_card_played method
	pass
