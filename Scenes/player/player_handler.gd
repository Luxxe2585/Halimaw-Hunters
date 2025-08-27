# Player turn order:
# 1. START_OF_TURN Relics
# 2. START_OF_TURN Statuses
# 3. Draw Hand
# 4. End TUrn
# 5. END_OF_TURN Relics
# 6. END_OF_TURN Statuses
# 7. Discard Hand
class_name PlayerHandler
extends Node

const HAND_DRAW_INTERVAL := 0.25
const HAND_DISCARD_INTERVAL := 0.25
const MAX_HAND_SIZE := 10

@export var relics: RelicHandler
@export var player: Player
@export var hand: Hand

var character: CharacterStats
var cards_played_this_combat := 0
var cards_played_this_turn := 0
var normality_in_hand := false



func _ready() -> void:
	Events.card_played.connect(_on_card_played)


func start_battle(char_stats: CharacterStats) -> void:
	character = char_stats
	character.draw_pile = character.deck.custom_duplicate()
	
	var innate_cards: Array[Card] = []
	var regular_cards: Array[Card] = []
	
	for card in character.draw_pile.cards:
		if card.innate:
			innate_cards.append(card)
		else:
			regular_cards.append(card)
	
	regular_cards.shuffle()
	
	character.draw_pile.cards = innate_cards + regular_cards
	character.discard = CardPile.new()
	relics.relics_activated.connect(_on_relics_activated)
	player.status_handler.statuses_applied.connect(_on_statuses_applied)
	Events.battle_started.emit()
	start_turn()
	Events.after_stats_battle_started.emit()


func start_turn() -> void:
	character.block = 0
	character.reset_mana()
	cards_played_this_turn = 0
	normality_in_hand = false
	_update_normality_status()
	Events.player_turn_started.emit()
	relics.activate_relics_by_type(Relic.Type.START_OF_TURN)


func end_turn() -> void:
	hand.disable_hand()
	relics.activate_relics_by_type(Relic.Type.END_OF_TURN)


func draw_card() -> void:
	if character.draw_pile.empty() and character.discard.empty():
		return
	
	reshuffle_deck_from_discard()
	
	var card = character.draw_pile.draw_card()
	if hand.get_child_count() >= MAX_HAND_SIZE:
		character.discard.add_card(card)
	else:
		hand.add_card(card)
		if card.id == "normality":
			normality_in_hand = true
			_update_hand_playability()
	
	_update_hand_playability()


func draw_cards(amount: int) -> void:
	var tween := create_tween()
	for i in range(amount):
		tween.tween_callback(draw_card)
		tween.tween_interval(HAND_DRAW_INTERVAL)
	
	tween.finished.connect(
		func(): Events.player_hand_drawn.emit()
	)


func discard_card(card) -> void:
	return


func discard_cards() -> void:
	if hand.get_child_count() == 0:
		Events.player_hand_discarded.emit()
		return
	
	var tween := create_tween()
	for card_ui in hand.get_children():
		if card_ui.card.ethereal:
			tween.tween_callback(hand.discard_card.bind(card_ui))
			tween.tween_interval(HAND_DISCARD_INTERVAL)
		else:
			tween.tween_callback(character.discard.add_card.bind(card_ui.card))
			tween.tween_callback(hand.discard_card.bind(card_ui))
			tween.tween_interval(HAND_DISCARD_INTERVAL)
	
	tween.finished.connect(
		func():
			Events.player_hand_discarded.emit()
	)


func reshuffle_deck_from_discard() -> void:
	if not character.draw_pile.empty():
		return
	
	while not character.discard.empty():
		character.draw_pile.add_card(character.discard.draw_card())
	
	character.draw_pile.shuffle()


func process_end_of_turn_card_effects() -> void:
	var cards_to_remove = []
	var empty_modifier_handler = ModifierHandler.new()  
	
	for card_ui in hand.get_children():
		var card : Card = card_ui.card
		
		if card and card is CurseCard:
			card.apply_effects([player], empty_modifier_handler)
		
		
		if card and card.ethereal:
			cards_to_remove.append(card_ui)
	
	
	for card_ui in cards_to_remove:
		hand.discard_card(card_ui)


func _on_card_played(card: Card) -> void:
	cards_played_this_turn += 1
	cards_played_this_combat += 1
	
	if card.id != "pain":
		_check_pain_curse()
	
	if normality_in_hand:
		_update_hand_playability()
	
	if card.exhausts or card.type == Card.Type.POWER:
		return
	
	character.discard.add_card(card)


func _check_pain_curse() -> void:
	for card_ui in hand.get_children():
		if card_ui.card.type == Card.Type.CURSE and card_ui.card.id == "pain":
			# Lose 1 HP when playing other cards
			player.stats.health -= 1
			player.stats.stats_changed.emit()
			break


func _update_normality_status() -> void:
	normality_in_hand = false
	for card_ui in hand.get_children():
		if card_ui.card.type == Card.Type.CURSE and card_ui.card.id == "normality":
			normality_in_hand = true
			break
	
	_update_hand_playability()


func _update_hand_playability() -> void:
	for card_ui in hand.get_children():
		var card = card_ui.card
		
		
		if normality_in_hand and cards_played_this_turn >= 3:
			card_ui.playable = false
		else:
			card_ui.playable = character.can_play_card(card) and not card.unplayable



func _on_statuses_applied(type: Status.Type) -> void:
	match type:
		Status.Type.START_OF_TURN:
			draw_cards(character.cards_per_turn)
		Status.Type.END_OF_TURN:
			process_end_of_turn_card_effects()
			discard_cards()


func _on_relics_activated(type: Relic.Type) -> void:
	match type:
		Relic.Type.START_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.START_OF_TURN)
		Relic.Type.END_OF_TURN:
			player.status_handler.apply_statuses_by_type(Status.Type.END_OF_TURN)	
