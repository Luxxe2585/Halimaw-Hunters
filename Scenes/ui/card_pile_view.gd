class_name CardPileView
extends Control

signal card_selected(card: Card)
const CARD_MENU_UI_SCENE := preload("res://Scenes/ui/card_menu_ui.tscn")

@export var card_pile: CardPile

@onready var title: Label = %Title
@onready var cards: GridContainer = %Cards
@onready var card_tooltip_popup: CardTooltipPopup = %CardTooltipPopup
@onready var back_button: Button = %BackButton


func  _ready() -> void:
	back_button.pressed.connect(hide)
	
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_tooltip_popup.hide_tooltip()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if card_tooltip_popup.visible:
			card_tooltip_popup.hide_tooltip()
		else:
			hide()




func show_current_view(new_title: String, randomized: bool = false, upgrade: bool = false) -> void:
	for card: Node in cards.get_children():
		card.queue_free()
	
	card_tooltip_popup.hide_tooltip()
	title.text = new_title
	_update_view.call_deferred(randomized)
	show()
	


func _update_view(randomized: bool, upgrade: bool = false) -> void:
	if not card_pile:
		return
	
	var all_cards := card_pile.cards.duplicate()
	if not randomized:
		all_cards.sort_custom(func(a, b): return a.name.nocasecmp_to(b.name) < 0)
	if randomized:
		RNG.array_shuffle(all_cards)
	
	for card: Card in all_cards:
		var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
		cards.add_child(new_card)
		new_card.card = card
		new_card.tooltip_requested.connect(
			func(c): 
				card_tooltip_popup.show_tooltip(c)
		)
		
		new_card.card_selected.connect(
			func(c): 
				emit_signal("card_selected", c)
		)
	
	show()

func get_back_button() -> Button:
	return back_button
