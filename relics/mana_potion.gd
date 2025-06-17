extends Relic


func activate_relic(owner: RelicUI) -> void:
	Events.after_stats_battle_started.connect(_add_mana.bind(owner))

func _add_mana(owner: RelicUI) -> void:
	owner.flash()
	var player := owner.get_tree().get_first_node_in_group("player") as Player
	if player:
		player.stats.mana += 1
