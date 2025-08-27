class_name CardMenuUI
extends CenterContainer

signal tooltip_requested(card: Card)
signal card_selected(card: Card)

const BASE_STYLEBOX := preload("res://Scenes/card_ui/card_base_stylebox.tres")
const HOVER_STYLEBOX:= preload("res://Scenes/card_ui/card_hover_stylebox.tres")
const SELECTED_STYLEBOX:= preload("res://Scenes/card_ui/card_dragging_stylebox.tres")

@export var card: Card : set = set_card
@export var upgrade_menu: bool = false
@export var remove_menu: bool = false

@onready var visuals: CardVisuals = $Visuals

var is_selected: bool = false
var is_hovered: bool = false
var deck_selector: Node

func _ready() -> void:
	# Find DeckSelector in the scene
	deck_selector = get_tree().get_first_node_in_group("deck_selector")


func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		tooltip_requested.emit(card)
		
		card_selected.emit(card)
		
		is_selected = !is_selected
		update_style()


func _on_visuals_mouse_entered() -> void:
	is_hovered = true
	update_style()


func _on_visuals_mouse_exited() -> void:
	is_hovered = false
	update_style()


func update_style() -> void:
	# Check if we're in a DeckSelector context
	var in_deck_selector = deck_selector && deck_selector.is_ancestor_of(self)
	
	if is_selected && in_deck_selector:
		visuals.panel.set("theme_override_styles/panel", SELECTED_STYLEBOX)
	elif is_hovered:
		visuals.panel.set("theme_override_styles/panel", HOVER_STYLEBOX)
	else:
		visuals.panel.set("theme_override_styles/panel", BASE_STYLEBOX)


func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	visuals.card = card
	
