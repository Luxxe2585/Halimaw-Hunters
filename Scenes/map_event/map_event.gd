class_name MapEvent
extends Control

@export var char_stats: CharacterStats
@export var relics: RelicHandler
@export var event: GameEvent
@export var run_stats: RunStats

@onready var eventpic: TextureRect = %EventPicture
@onready var title: Label = %EventTitle
@onready var description: Label = %EventText
@onready var button1: Button = %Button1
@onready var button2: Button = %Button2
@onready var button3: Button = %Button3

signal event_completed

var current_event: GameEvent

func setup_from_resource(event: GameEvent) -> void:
	current_event = event
	
	if event and event.event_picture:
		eventpic.texture = event.event_picture
	else:
		eventpic.texture = null
	
	title.text = event.event_title if event else "No Event"
	description.text = event.event_text if event else ""

	if event and event.has_method("setup_buttons"):
		event.setup_buttons(self)
	
	update_buttons(
		event.button1_text if event else "", 
		event.button1_enabled if event else false,
		event.button2_text if event else "", 
		event.button2_enabled if event else false,
		event.button3_text if event else "", 
		event.button3_enabled if event else false
	)
	
	connect_buttons()

func update_buttons(btn1_text: String, btn1_enabled: bool, 
				   btn2_text: String, btn2_enabled: bool, 
				   btn3_text: String, btn3_enabled: bool) -> void:
	
	button1.text = btn1_text
	button1.visible = btn1_text != ""
	button1.disabled = not btn1_enabled
	
	button2.text = btn2_text
	button2.visible = btn2_text != ""
	button2.disabled = not btn2_enabled
	
	button3.text = btn3_text
	button3.visible = btn3_text != ""
	button3.disabled = not btn3_enabled

func connect_buttons() -> void:
	for button in [button1, button2, button3]:
		for connection in button.pressed.get_connections():
			if connection.callable.get_method() == "_on_button1_pressed" or \
			   connection.callable.get_method() == "_on_button2_pressed" or \
			   connection.callable.get_method() == "_on_button3_pressed":
				button.pressed.disconnect(connection.callable)
	
	if button1.visible:
		button1.pressed.connect(_on_button1_pressed)
	
	if button2.visible:
		button2.pressed.connect(_on_button2_pressed)
	
	if button3.visible:
		button3.pressed.connect(_on_button3_pressed)

func _on_button1_pressed() -> void:
	if current_event and current_event.has_method("handle_button_click"):
		current_event.handle_button_click(0, self)

func _on_button2_pressed() -> void:
	if current_event and current_event.has_method("handle_button_click"):
		current_event.handle_button_click(1, self)

func _on_button3_pressed() -> void:
	if current_event and current_event.has_method("handle_button_click"):
		current_event.handle_button_click(2, self)

func _finish_event() -> void:
	event_completed.emit()
	queue_free()
