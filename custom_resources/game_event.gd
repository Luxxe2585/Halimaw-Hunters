class_name GameEvent
extends Resource

@export var event_picture: CompressedTexture2D
@export var event_title: String
@export_multiline var event_text: String

@export var button1_text: String
@export var button1_enabled: bool = true
@export var button2_text: String
@export var button2_enabled: bool = false
@export var button3_text: String
@export var button3_enabled: bool = false

@export var quiz_event: GameEvent

func setup_buttons(map_event: MapEvent) -> void:
	pass

func handle_button_click(button_index: int, map_event: MapEvent) -> void:
	push_error("Button handler not implemented for this event")
