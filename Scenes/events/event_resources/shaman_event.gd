class_name ShamanEvent
extends GameEvent

var selected_option: int = -1

func setup_buttons(map_event: MapEvent) -> void:
	if map_event.run_stats.gold < 50:
		button1_enabled = false
		button2_enabled = false

func handle_button_click(button_index: int, map_event: MapEvent) -> void:
	if selected_option == -1:
		selected_option = button_index
		
		match button_index:
			0:
				map_event.description.text = "A hand reaches for you and impurities are extracted. Your shoulders feel a little lighter."
			1:
				map_event.description.text = "There's a shift in the air. The beljan communicates with higher beings to bless you."
			2:
				map_event.description.text = "The beljan touches your shoulder, warmth floods through you, and your wounds begin to close."
		
		map_event.update_buttons("Ok", true, "", false, "", false)
		map_event.connect_buttons()
	else:
		match selected_option:
			0:
				Events.open_deck_selector_remove.emit(1)
				Events.deck_selector_completed.connect(
					func(_cards):
						map_event.run_stats.gold -= 50
						map_event._finish_event()
				, CONNECT_ONE_SHOT)
				Events.deck_selector_exited.connect(
					func():
						map_event._finish_event()
				, CONNECT_ONE_SHOT)
			1:
				Events.open_deck_selector_upgrade.emit(1)
				Events.deck_selector_completed.connect(
					func(_cards):
						map_event.run_stats.gold -= 50
						map_event._finish_event()
				, CONNECT_ONE_SHOT)
				Events.deck_selector_exited.connect(
					func():
						map_event._finish_event()
				, CONNECT_ONE_SHOT)
			2:
				map_event.char_stats.heal(20)
				map_event._finish_event()
