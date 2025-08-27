class_name DeckSelector
extends Control

signal selection_completed()
signal card_selected(card: Card)

@export var character_stats: CharacterStats

@onready var card_pile_view: CardPileView = %CardPileView
@onready var card_tooltip_popup: CardTooltipPopup = card_pile_view.card_tooltip_popup
@onready var upgrade_button: Button = %UpgradeButton
@onready var remove_button: Button = %RemoveButton
@onready var selections_label: Label = %SelectionsLabel

enum Mode { REMOVE, UPGRADE }
var mode: Mode = Mode.REMOVE
var selections_remaining: int = 0
var selected_cards: Array[Card] = []
var filtered_deck: CardPile = CardPile.new()

func _ready() -> void:
	card_tooltip_popup.hide_tooltip()
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	remove_button.pressed.connect(_on_remove_button_pressed)
	
	card_tooltip_popup.tooltip_hidden.connect(_on_tooltip_hidden)
	card_tooltip_popup.tooltip_shown.connect(_on_tooltip_shown)
	
	call_deferred("_connect_back_button")
	
	# Hide buttons initially
	upgrade_button.hide()
	remove_button.hide()


func _connect_back_button() -> void:
	if card_pile_view and card_pile_view.get_back_button():
		card_pile_view.get_back_button().pressed.connect(_on_back_button_pressed)
	else:
		push_error("card_pile_view or back_button is null in DeckSelector")


func show_in_mode(mode_type: Mode, amount: int) -> void:
	if not is_node_ready():
		await ready
	
	mode = mode_type
	selections_remaining = amount
	selected_cards.clear()
	
	# Set title based on mode
	var title: String
	match mode:
		Mode.UPGRADE:
			title = "Select cards to Upgrade"
			# Filter deck to only cards with upgrades
			filtered_deck.cards = character_stats.deck.cards.filter(func(card): return card.upgrade != null)
			card_pile_view.card_pile = filtered_deck
		Mode.REMOVE:
			title = "Select cards to Remove"
			card_pile_view.card_pile = character_stats.deck
		_:
			push_error("Invalid DeckSelector mode")
			return
	
	if card_pile_view.card_selected.is_connected(_on_card_selected):
		card_pile_view.card_selected.disconnect(_on_card_selected)
	card_pile_view.card_selected.connect(_on_card_selected)
	
	card_pile_view.show_current_view(title)
	update_selections_label()
	show()

func _on_upgrade_button_pressed() -> void:
	if selected_cards.is_empty(): 
		return
	
	for card in selected_cards:
		if card.upgrade:
			var index = character_stats.deck.cards.find(card)
			if index != -1:
				character_stats.deck.cards[index] = card.upgrade
				character_stats.deck.card_pile_size_changed.emit(character_stats.deck.cards.size())
	
	complete_selection()

func _on_remove_button_pressed() -> void:
	if selected_cards.is_empty(): 
		return
	
	for card in selected_cards:
		character_stats.deck.remove_card(card)
	
	complete_selection()

func complete_selection() -> void:
	hide()
	var removed_cards = selected_cards.duplicate()
	selected_cards.clear()
	selection_completed.emit(removed_cards)
	

func update_selections_label() -> void:
	if selections_remaining > 1:
		selections_label.text = "Select up to %d more cards" % selections_remaining
		selections_label.show()
	else:
		selections_label.hide()

func _on_back_button_pressed() -> void:
	Events.deck_selector_exited.emit()
	selected_cards.clear()
	hide()

func _on_card_selected(card: Card) -> void:
	if card in selected_cards:
		# Deselect if already selected
		selected_cards.erase(card)
	else:
		if selected_cards.size() < selections_remaining:
			selected_cards.append(card)
	
	# Show tooltip for the last selected card, if any
	if selected_cards.size() > 0:
		card_tooltip_popup.show_tooltip(selected_cards[-1])
	else:
		card_tooltip_popup.hide_tooltip()
	
	# Enable buttons only if exactly required amount selected
	if selected_cards.size() > 0:
		if mode == Mode.UPGRADE:
			upgrade_button.show()
			remove_button.hide()
		else:
			upgrade_button.hide()
			remove_button.show()
	else:
		upgrade_button.hide()
		remove_button.hide()
	update_selections_label()


func _on_tooltip_shown() -> void:
	upgrade_button.hide()
	remove_button.hide()

func _on_tooltip_hidden() -> void:
	if selected_cards.size() > 0:
		if mode == Mode.UPGRADE:
			upgrade_button.show()
		else:
			remove_button.show()
