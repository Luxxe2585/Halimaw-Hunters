extends  EnemyAction

const STRENGTH_STATUS = preload("res://statuses/strength.tres")

@export var stacks_per_action := 2


func is_performable() -> bool:
	if (enemy.stats.sequence_order % 3) == 1:
		return true
	
	return false


func perform_action() -> void:
	if not enemy or not target:
		return
	
	var status_effect := StatusEffect.new()
	var strength := STRENGTH_STATUS.duplicate()
	strength.stacks = stacks_per_action
	status_effect.status = strength
	status_effect.execute([enemy])
	
	enemy.stats.sequence_order += 1
	
	SFXPlayer.play(sound)
	
	Events.enemy_action_completed.emit(enemy)
