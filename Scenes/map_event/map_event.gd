extends Control


func _on_button_pressed() -> void:
	Events.map_event_exited.emit()
