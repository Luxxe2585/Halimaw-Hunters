class_name EventSystem
extends Node

@export var event_pool: GameEventPool
var queued_quiz_events: Array[Resource] = []

#Add this to events that start battles
#Run.current_battle_source = "event"

func trigger_post_battle_event() -> void:
	var event := event_pool.get_random_event()
	if event:
		_show_event_scene(event)
	else:
		# no more events left, just continue back to map
		Events.map_event_exited.emit()

func _show_event_scene(event: GameEvent) -> void:
	var event_scene := preload("res://Scenes/map_event/map_event.tscn").instantiate() as MapEvent
	event_scene.char_stats = (get_tree().root.get_node("Run") as Run).character
	event_scene.run_stats = (get_tree().root.get_node("Run") as Run).stats
	event_scene.relics = (get_tree().root.get_node("Run") as Run).relic_handler
	
	event_scene.call_deferred("setup_from_resource", event)
	event_scene.event_completed.connect(func(): _on_event_completed(event))
	get_tree().current_scene.add_child(event_scene)

func _on_event_completed(event: GameEvent) -> void:
	if event.quiz_event:
		queued_quiz_events.append(event.quiz_event)
	Events.map_event_exited.emit()

func trigger_quiz_event_sequence() -> void:
	for quiz in queued_quiz_events:
		_trigger_quiz_event(quiz)
	# after finishing all quizzes, clear them
	queued_quiz_events.clear()

func _trigger_quiz_event(quiz_event: GameEvent) -> void:
	
	pass
