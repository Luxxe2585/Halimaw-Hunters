extends EnemyAction

@export var damage := 24

func is_performable() -> bool:
	if not enemy:
		return false
	
	return enemy.stats.is_readied


func  perform_action() -> void:
	if not enemy or not target:
		return
	
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	damage_effect.amount = damage
	damage_effect.sound = sound
	
	enemy.stats.is_readied = false
	
	get_tree().create_timer(0.6, false).timeout.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
			)
