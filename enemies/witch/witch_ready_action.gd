extends EnemyAction


func is_performable() -> bool:
	if not enemy or enemy.stats.block != 15:
		return false
	
	return true


func perform_action() -> void:
	if not enemy or not target:
		return
	
	# Set ready state on enemy stats
	enemy.stats.is_readied = true
	
	get_tree().create_timer(0.6, false).timeout.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
			# Signal that ready state is complete
			Events.enemy_readied.emit(enemy)
			)
			
