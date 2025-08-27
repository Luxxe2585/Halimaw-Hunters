extends Card

const  TRUE_STRENGTH_FORM_STATUS = preload("res://statuses/true_strength_form.tres")

var strength_per_turn = 2

func get_default_tooltip() -> String:
	return tooltip_text


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var true_strength := TRUE_STRENGTH_FORM_STATUS.duplicate()
	
	true_strength.stacks = strength_per_turn
	status_effect.sound = sound
	status_effect.status = true_strength
	status_effect.execute(targets)
