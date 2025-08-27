class_name Hand
extends Control

@export var player: Player
@export var char_stats: CharacterStats
@export var arc_height: float = 15.0  
@export var hover_elevation: float = 10.0  
@export var hover_scale: float = 1.2  
@export var animation_speed: float = 0.09  

@export var spacing_factor: float = 0.7        # < 1.0 = overlap; > 1.0 = gaps
@export var rotation_range_deg: float = 8.0    # tilt spread across the hand
@export var neighbor_push_px: float = 20.0     # how far neighbors move on hover


@onready var card_ui := preload("res://Scenes/card_ui/card_ui.tscn")
var hovered_card: CardUI = null


func add_card(card: Card) -> void:
	var new_card_ui := card_ui.instantiate()
	add_child(new_card_ui)
	new_card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
	new_card_ui.card = card
	new_card_ui.parent = self
	new_card_ui.char_stats = char_stats
	new_card_ui.player_modifiers = player.modifier_handler

	new_card_ui.mouse_entered.connect(_on_card_hover_started.bind(new_card_ui))
	new_card_ui.mouse_exited.connect(_on_card_hover_ended.bind(new_card_ui))
	
	arrange_cards()

func discard_card(card: CardUI) -> void:
	if card.is_connected("mouse_entered", _on_card_hover_started):
		card.mouse_entered.disconnect(_on_card_hover_started)
	if card.is_connected("mouse_exited", _on_card_hover_ended):
		card.mouse_exited.disconnect(_on_card_hover_ended)
	
	card.queue_free()
	arrange_cards()


func disable_hand() -> void:
	for card in get_children():
		card.disabled = true


func arrange_cards() -> void:
	var card_count := get_child_count()
	if card_count == 0:
		return

	
	var center_x := size.x * 0.5

	for i in range(card_count):
		var card := get_child(i) as CardUI
		if card == null:
			continue

		var t : float = (i as float) / max(1, card_count - 1)   
		var x_centered := center_x + (i - (card_count - 1) / 2.0) * (card.size.x * spacing_factor)
		var base_y := size.y - card.size.y              
		var y_arc := -sin(t * PI) * arc_height          

		var target_pos := Vector2(x_centered - card.size.x / 2.0, base_y + y_arc)
		var target_scale := Vector2.ONE
		var target_rotation := deg_to_rad(lerp(-rotation_range_deg, rotation_range_deg, t))

		# Hover effects
		if card == hovered_card:
			target_pos.y -= hover_elevation
			target_scale = Vector2.ONE * hover_scale
			target_rotation = 0.0
			card.z_index = card_count + 1
		else:
			card.z_index = i
			if hovered_card:
				var hovered_index := hovered_card.get_index()
				var distance : int = abs(i - hovered_index)
				if distance == 1:
					target_pos.x += (-neighbor_push_px if i < hovered_index else neighbor_push_px)
				elif distance == 2:
					target_pos.x += (-(neighbor_push_px * 0.5) if i < hovered_index else (neighbor_push_px * 0.5))

		animate_card(card, target_pos, target_scale, target_rotation)


func animate_card(card: CardUI, position: Vector2, scale: Vector2, rotation: float) -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "position", position, animation_speed)
	tween.tween_property(card, "scale", scale, animation_speed)
	tween.tween_property(card, "rotation", rotation, animation_speed)

func _on_card_hover_started(card: CardUI) -> void:
	hovered_card = card
	arrange_cards()

func _on_card_hover_ended(card: CardUI) -> void:
	if hovered_card == card:
		hovered_card = null
		arrange_cards()


func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.disabled = true
	child.reparent(self)
	var new_index := clampi(child.original_index, 0, get_child_count())
	move_child.call_deferred(child, new_index)
	child.set_deferred("disabled", false)
	arrange_cards()
