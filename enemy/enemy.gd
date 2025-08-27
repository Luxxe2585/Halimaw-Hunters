class_name Enemy
extends Area2D

const ARROW_OFFSET := 5
const WHITE_SPRITE_MATERIAL := preload("res://global/art/white_sprite_material.tres")
const UI_SPACING := 2

@export var stats: EnemyStats : set = set_enemy_stats

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arrow: Sprite2D = $Arrow
@onready var stats_ui: StatsUI = $StatsUI 
@onready var intent_ui: IntentUI = $IntentUI 
@onready var status_handler: StatusHandler = $StatusHandler
@onready var modifier_handler: ModifierHandler = $ModifierHandler
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var enemy_action_picker: EnemyActionPicker
var current_action: EnemyAction : set = set_current_action


func _ready() -> void:
	status_handler.status_owner = self


func set_current_action(value: EnemyAction) -> void:
	current_action = value
	update_intent()


func set_enemy_stats(value: EnemyStats) -> void:
	stats = value.create_instance()
	
	if not stats.stats_changed.is_connected(update_stats):
		stats.stats_changed.connect(update_stats)
		stats.stats_changed.connect(update_action)
	
	update_enemy()
	

func setup_ai() -> void:
	if enemy_action_picker:
		enemy_action_picker.queue_free()
	
	var new_action_picker: EnemyActionPicker = stats.ai.instantiate()
	add_child(new_action_picker)
	enemy_action_picker = new_action_picker
	enemy_action_picker.enemy = self


func update_stats() -> void:
	stats_ui.update_stats(stats)


func update_action() -> void:
	if not enemy_action_picker:
		return
	
	if not current_action:
		current_action = enemy_action_picker.get_action()
		return
	
	var new_conditional_action := enemy_action_picker.get_first_conditional_action()
	if new_conditional_action and current_action != new_conditional_action:
		current_action = new_conditional_action


func update_enemy() -> void:
	if not stats is Stats:
		return
	if not is_inside_tree():
		await ready
	
	sprite_2d.texture = stats.art
	var scaled_sprite_size = sprite_2d.get_rect().size * sprite_2d.scale
	arrow.position = Vector2.RIGHT * (sprite_2d.get_rect().size.x / 2 + ARROW_OFFSET)
	collision_shape.shape.size = scaled_sprite_size
	setup_ai()
	update_stats()
	call_deferred("position_ui_elements")


func position_ui_elements() -> void:
	var sprite_size = sprite_2d.get_rect().size * sprite_2d.scale
	var sprite_top = -sprite_size.y / 2
	var sprite_bottom = sprite_size.y / 2
	
	# Position intent_ui above sprite
	if intent_ui:
		intent_ui.position.y = sprite_top - intent_ui.size.y - UI_SPACING
	
	# Position stats_ui below sprite
	if stats_ui:
		stats_ui.position.y = sprite_bottom + UI_SPACING
		
		# Position status_handler below stats_ui
		if status_handler:
			status_handler.position.y = stats_ui.position.y + stats_ui.size.y + UI_SPACING


func update_intent() -> void:
	if current_action:
		current_action.update_intent_text()
		intent_ui.update_intent(current_action.intent)


func do_turn() -> void:
	stats.block = 0
	
	if not current_action:
		return
	
	current_action.perform_action()


func get_modified_block_gain(base_block: int) -> int:
	return modifier_handler.get_modified_value(base_block, Modifier.Type.BLOCK_GAINED)


func take_damage(damage: int, which_modifier: Modifier.Type) -> void:
	if stats.health <= 0:
		return
	
	sprite_2d.material = WHITE_SPRITE_MATERIAL
	var modified_damage := modifier_handler.get_modified_value(damage, which_modifier)
	
	var tween := create_tween()
	tween.tween_callback(Shaker.shake.bind(self, 16, 0.15))
	tween.tween_callback(stats.take_damage.bind(modified_damage))
	tween.tween_interval(0.17)
	
	tween.finished.connect(
		func():
			sprite_2d.material = null
			
			if stats.health <= 0:
				Events.enemy_died.emit(self)
				queue_free()
	)


func _on_area_entered(_area: Area2D) -> void:
	arrow.show()


func _on_area_exited(_area: Area2D) -> void:
	arrow.hide()
