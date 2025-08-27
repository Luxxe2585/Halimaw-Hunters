class_name Treasure
extends Control

@export var relic_pool: RelicPool
@export var relic_handler: RelicHandler
@export var char_stats: CharacterStats
@export var background_art: CompressedTexture2D:
	set(value):
		background_art = value
		if background:  
			background.texture = background_art


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var background: TextureRect = %Background
var found_relic: Relic

func generate_relic() -> void:
	if not relic_pool:
		return
		
	var available_relics := relic_pool.relics.filter(
		func(relic: Relic):
			var can_appear := relic.can_appear_as_reward(char_stats)
			var already_had_it := relic_handler.has_relic(relic.id)
			return can_appear and not already_had_it
	)
	
	if available_relics.is_empty():
		push_error("No valid relics available in treasure room")
		found_relic = null
		return
		
	found_relic = RNG.array_pick_random(available_relics)


# Called from the AnimationPlayer, at the end
# of the 'open' animation.
func _on_treasure_opened() -> void:
	Events.treasure_room_exited.emit(found_relic)

func _on_treasure_chest_gui_input(event: InputEvent) -> void:
	if animation_player.current_animation == "open":
		return
	
	if event.is_action_pressed("left_mouse"):
		animation_player.play("open")
