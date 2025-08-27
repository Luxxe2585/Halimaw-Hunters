class_name CardDiscardEffect
extends Effect

var card_target: CardUI  

#need to create a scene that lets the player select a card to discard
func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		return
		
	var player_handler := targets[0].get_tree().get_first_node_in_group("player_handler") as PlayerHandler
	
	if not player_handler:
		return
	
	player_handler.discard_card(card_target)
