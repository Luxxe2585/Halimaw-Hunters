extends Card

const  REGEN_STATUS = preload("res://statuses/regen.tres")

var base_regen := 3



func get_default_tooltip() -> String:
	return tooltip_text % base_regen


func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var status_effect := StatusEffect.new()
	var regen := REGEN_STATUS.duplicate()
	
	regen.duration = base_regen
	status_effect.status = regen
	status_effect.execute(targets)
	

	var card_draw_effect := CardDrawEffect.new()
	card_draw_effect.cards_to_draw = 1
	card_draw_effect.execute(targets)
