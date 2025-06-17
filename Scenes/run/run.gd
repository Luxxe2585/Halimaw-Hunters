class_name Run
extends Node

const BATTLE_SCENE := preload("res://Scenes/battle/battle.tscn")
const BATTLE_REWARD_SCENE := preload("res://Scenes/battle_reward/battle_reward.tscn")
const CAMPFIRE_SCENE := preload("res://Scenes/campfire/campfire.tscn")
const SHOP_SCENE := preload("res://Scenes/shop/shop.tscn")
const TREASURE_SCENE := preload("res://Scenes/treasure/treasure.tscn")
const EVENT_SCENE := preload("res://Scenes/map_event/map_event.tscn")
const WIN_SCREEN_SCENE := preload("res://Scenes/win_screen/win_screen.tscn")
const MAIN_MENU_PATH := "res://Scenes/ui/main_menu.tscn"

@export var run_startup: RunStartup
@export var relic_pool: RelicPool

@onready var map: Map = $Map
@onready var current_view: Node = $CurrentView
@onready var health_ui: HealthUI = %HealthUI
@onready var gold_ui: GoldUI = %GoldUI
@onready var relic_handler: RelicHandler = %RelicHandler
@onready var relic_tooltip: RelicTooltip = %RelicTooltip
@onready var deck_button: CardPileButton = %DeckButton
@onready var deck_view: CardPileView = %DeckView
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var act_text: ActText = $ActText

@onready var battle_button: Button = %BattleButton
@onready var campfire_button: Button = %CampfireButton
@onready var map_button: Button = %MapButton
@onready var rewards_button: Button = %RewardsButton
@onready var shop_button: Button = %ShopButton
@onready var treasure_button: Button = %TreasureButton
@onready var event_button: Button = %EventButton

var stats: RunStats
var character: CharacterStats
var save_data: SaveGame


func _ready() -> void:
	if not run_startup:
		return
	
	pause_menu.save_and_quit.connect(
		func():
			get_tree().change_scene_to_file(MAIN_MENU_PATH)
	)
	
	match run_startup.type:
		RunStartup.Type.NEW_RUN:
			character = run_startup.picked_character.create_instance()
			_start_run()
		RunStartup.Type.CONTINUED_RUN:
			_load_run()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat"):
		get_tree().call_group("enemies", "queue_free")


func _start_run() -> void:
	stats = RunStats.new()
	
	_setup_event_connections()
	_setup_top_bar()
	map.generate_new_map()
	map.unlock_floor(0)
	
	call_deferred("_show_act_text")
	
	save_data = SaveGame.new()
	_save_run(true)
	
	map.animate_camera_scroll(1.25, 2.25)


func _save_run(was_on_map: bool) -> void:
	save_data.rng_seed = RNG.instance.seed
	save_data.rng_state = RNG.instance.state
	save_data.run_stats = stats
	save_data.char_stats = character
	save_data.current_deck = character.deck
	save_data.current_health = character.health
	save_data.relics = relic_handler.get_all_relics()
	save_data.last_room = map.last_room
	save_data.map_data = map.map_data.duplicate()
	save_data.floors_climbed = map.floors_climbed
	save_data.was_on_map = was_on_map
	save_data.save_data()


func _load_run() -> void:
	save_data = SaveGame.load_data()
	assert(save_data, "Couldn't load last save")
	
	RNG.set_from_save_data(save_data.rng_seed, save_data.rng_state)
	stats = save_data.run_stats
	character = save_data.char_stats
	character.deck = save_data.current_deck
	character.health = save_data.current_health
	relic_handler.add_relics(save_data.relics)
	_setup_top_bar()
	_setup_event_connections()
	
	map.load_map(save_data.map_data, save_data.floors_climbed, save_data.last_room)
	map.camera_2d.position.y = map.camera_edge_y
	map._clamp_camera_position()
	if save_data.last_room and not save_data.was_on_map:
		_on_map_exited(save_data.last_room)



func _show_act_text() -> void:
	if act_text:
		act_text.update_act_text(stats.current_level)
		act_text.play_act_animation()

func _generate_next_level() -> void:
	#This needs to be edited. Currently works but there's weird pause at the start
	map.clear_map()
	map.generate_new_map()
	map.unlock_floor(0)
	stats.current_level += 1
	
	
	map.camera_2d.position.y = map.initial_camera_position
	map._clamp_camera_position()
	
	if current_view.get_child_count() > 0 :
		current_view.get_child(0).queue_free()
	
	map.show_map()
	call_deferred("_show_act_text")
	
	map.animate_camera_scroll(1.25, 2.25)
	
	_save_run(true)


func _change_view(scene: PackedScene) -> Node:
	if current_view.get_child_count() > 0:
		current_view.get_child(0).queue_free()
	
	get_tree().paused = false
	var new_view := scene.instantiate()
	current_view.add_child(new_view)
	map.hide_map()
	
	return new_view


func _show_map() -> void:
	if current_view.get_child_count() > 0 :
		current_view.get_child(0).queue_free()
	
	map.show_map()
	map.unlock_next_rooms()
	
	_save_run(true)


func _setup_event_connections() -> void:
	Events.battle_won.connect(_on_battle_won)
	Events.battle_reward_exited.connect(_show_map)
	Events.campfire_exited.connect(_show_map)
	Events.map_exited.connect(_on_map_exited)
	Events.shop_exited.connect(_show_map)
	Events.treasure_room_exited.connect(_on_treasure_room_exited)
	Events.map_event_exited.connect(_show_map)
	
	battle_button.pressed.connect(_change_view.bind(BATTLE_SCENE))
	campfire_button.pressed.connect(_change_view.bind(CAMPFIRE_SCENE))
	map_button.pressed.connect(_show_map)
	rewards_button.pressed.connect(_change_view.bind(BATTLE_REWARD_SCENE))
	shop_button.pressed.connect(_change_view.bind(SHOP_SCENE))
	treasure_button.pressed.connect(_change_view.bind(TREASURE_SCENE))
	event_button.pressed.connect(_change_view.bind(EVENT_SCENE))


func _setup_top_bar():
	character.stats_changed.connect(health_ui.update_stats.bind(character))
	health_ui.update_stats(character)
	gold_ui.run_stats = stats
	
	relic_handler.add_relic(character.starting_relic)
	Events.relic_tooltip_requested.connect(relic_tooltip.show_tooltip)
	
	deck_button.card_pile = character.deck
	deck_view.card_pile = character.deck
	deck_button.pressed.connect(deck_view.show_current_view.bind("Deck"))


func _show_regular_battle_rewards() -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.relic_handler = relic_handler
	
	reward_scene.add_gold_reward(map.last_room.battle_stats.roll_gold_reward())
	reward_scene.add_card_reward()
	
	# Add relic reward for Elite rooms
	if map.last_room and map.last_room.type == Room.Type.ELITE:
		var relic = _get_random_relic()
		if relic:
			reward_scene.add_relic_reward(relic)


func _get_random_relic() -> Relic:
	var available_relics := relic_pool.relics.filter(
		func(relic: Relic):
			var can_appear := relic.can_appear_as_reward(character)
			var already_had_it := relic_handler.has_relic(relic.id)
			return can_appear and not already_had_it
	)
	
	if available_relics.is_empty():
		push_error("No valid relics available for reward")
		return null
	
	return RNG.array_pick_random(available_relics)


func _on_battle_room_entered(room: Room) -> void:
	var battle_scene: Battle = _change_view(BATTLE_SCENE) as Battle
	battle_scene.char_stats = character
	battle_scene.battle_stats = room.battle_stats
	battle_scene.relics = relic_handler
	battle_scene.start_battle()


func _on_treasure_room_entered() -> void:
	var treasure_scene := _change_view(TREASURE_SCENE) as Treasure
	treasure_scene.relic_handler = relic_handler
	treasure_scene.char_stats = character
	treasure_scene.generate_relic()


func _on_treasure_room_exited(relic: Relic) -> void:
	var reward_scene := _change_view(BATTLE_REWARD_SCENE) as BattleReward
	reward_scene.run_stats = stats
	reward_scene.character_stats = character
	reward_scene.relic_handler = relic_handler
	
	var gold_amount := RNG.instance.randi_range(110, 155)
	
	reward_scene.add_relic_reward(relic)
	reward_scene.add_gold_reward(gold_amount)


func _on_campfire_entered() -> void:
	var campfire := _change_view(CAMPFIRE_SCENE) as Campfire
	campfire.char_stats = character


func _on_shop_entered() -> void:
	var shop := _change_view(SHOP_SCENE) as Shop
	shop.char_stats = character
	shop.run_stats = stats
	shop.relic_handler = relic_handler
	Events.shop_entered.emit(shop)
	shop.populate_shop()


func _on_battle_won() -> void:
	if map.floors_climbed == MapGenerator.FLOORS:
		if stats.current_level == 3:
			var win_screen := _change_view(WIN_SCREEN_SCENE) as WinScreen
			win_screen.character = character
			SaveGame.delete_data()
		else:
			_generate_next_level()
	else:
		_show_regular_battle_rewards()


func  _on_map_exited(room: Room) -> void:
	_save_run(false)
	
	match room.type:
		Room.Type.MONSTER:
			_on_battle_room_entered(room)
		Room.Type.TREASURE:
			_on_treasure_room_entered()
		Room.Type.CAMPFIRE:
			_on_campfire_entered()
		Room.Type.SHOP:
			_on_shop_entered()
		Room.Type.EVENT:
			_change_view(EVENT_SCENE)
		Room.Type.ELITE:
			_on_battle_room_entered(room)
		Room.Type.BOSS:
			_on_battle_room_entered(room)
