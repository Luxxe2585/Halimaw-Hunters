class_name SimpleHealEvent
extends GameEvent

func handle_button_click(button_index: int, map_event: MapEvent) -> void:
	print("SimpleHealEvent: handle_button_click called with button_index: ", button_index)
	
	if button_index == 0:  # Only one button for this event
		print("SimpleHealEvent: Healing player")
		map_event.char_stats.heal(10)
		map_event._finish_event()
	else:
		print("SimpleHealEvent: Unexpected button index: ", button_index)
