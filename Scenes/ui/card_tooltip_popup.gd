class_name CardTooltipPopup
extends Control

signal tooltip_hidden
signal tooltip_shown

const CARD_MENU_UI_SCENE := preload("res://Scenes/ui/card_menu_ui.tscn")

@export var background_color: Color = Color("000000b0")

@onready var background: ColorRect = $Background
@onready var tooltip_card: CenterContainer = %TooltipCard
@onready var card_description: RichTextLabel = %CardDescription
@onready var show_upgrades: Button = %ShowUpgradeButton
@onready var hide_upgrades: Button = %HideUpgradeButton

var original_card: Card  # Store the original card for reverting
var upgraded_card: Card  # Store the upgraded version


func _ready() -> void:
	for card: CardMenuUI in tooltip_card.get_children():
		card.queue_free()
	
	background.color = background_color
	show_upgrades.visible = true
	hide_upgrades.visible = false


func show_tooltip(card: Card) -> void:
	original_card = card
	upgraded_card = card.upgrade if card else null
	
	# Clear any existing cards
	for child in tooltip_card.get_children():
		child.queue_free()
	
	# Add the original card
	var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	tooltip_card.add_child(new_card)
	new_card.card = card
	new_card.tooltip_requested.connect(hide_tooltip.unbind(1))
	
	# Set description and button visibility
	card_description.text = card.get_default_tooltip()
	show_upgrades.visible = upgraded_card != null
	hide_upgrades.visible = false
	
	show()
	emit_signal("tooltip_shown")


func hide_tooltip() -> void:
	if not visible:
		return
	
	for card: CardMenuUI in tooltip_card.get_children():
		card.queue_free()
	
	hide()
	emit_signal("tooltip_hidden")


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_tooltip()


func _on_show_upgrade_button_pressed() -> void:
	if not upgraded_card:
		return
	
	# Clear current card
	for child in tooltip_card.get_children():
		child.queue_free()
	
	# Add upgraded card
	var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	tooltip_card.add_child(new_card)
	new_card.card = upgraded_card
	new_card.tooltip_requested.connect(hide_tooltip.unbind(1))
	
	# Update description and buttons
	card_description.text = upgraded_card.get_default_tooltip()
	show_upgrades.visible = false
	hide_upgrades.visible = true


func _on_hide_upgrade_button_pressed() -> void:
	if not original_card:
		return
	
	# Clear current card
	for child in tooltip_card.get_children():
		child.queue_free()
	
	# Add original card
	var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	tooltip_card.add_child(new_card)
	new_card.card = original_card
	new_card.tooltip_requested.connect(hide_tooltip.unbind(1))
	
	# Update description and buttons
	card_description.text = original_card.get_default_tooltip()
	show_upgrades.visible = true
	hide_upgrades.visible = false
