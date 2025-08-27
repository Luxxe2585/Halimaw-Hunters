extends CurseCard

var cards_played_this_turn := 0
var max_cards_per_turn := 3


func get_default_tooltip() -> String:
	return tooltip_text
