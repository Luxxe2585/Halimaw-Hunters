class_name MapGenerator
extends Node

const X_DIST := 30
const Y_DIST := 25
const  PLACEMENT_RANDOMNESS := 5
const FLOORS := 12
const MAP_WIDTH := 7
const PATHS := 6
const MONSTER_ROOM_WEIGHT := 3.7
const ELITE_ROOM_WEIGHT := 1.3
const QUIZ_EVENT_ROOM_WEIGHT := 0.0
const CAMPFIRE_ROOM_WEIGHT := 1.0
const SHOP_ROOM_WEIGHT := 1.0

@export var battle_stats_pool: BattleStatsPool


var random_room_type_weights = {
	Room.Type.MONSTER: 0.0,
	Room.Type.CAMPFIRE: 0.0,
	Room.Type.SHOP: 0.0,
	Room.Type.ELITE: 0.0,
	Room.Type.QUIZ_EVENT: 0.0,
}
var random_room_type_total_weight := 0
var map_data: Array[Array]


func generate_map() -> Array[Array]:
	map_data = _generate_initial_grid()
	var starting_points := _get_random_starting_points()
	
	for j in starting_points:
		var current_j := j
		for i in FLOORS - 1:
			current_j = _setup_connection(i, current_j)
	
	battle_stats_pool.setup()
	
	_setup_boss_room()
	_setup_random_room_weights()
	_setup_room_types()
	
	return map_data


func _generate_initial_grid() -> Array[Array]:
	var result: Array[Array] = []
	
	for i in FLOORS:
		var adjacent_rooms: Array[Room] = []
		
		for j in MAP_WIDTH:
			var current_room := Room.new()
			var offset := Vector2(randf(), randf()) * PLACEMENT_RANDOMNESS
			current_room.position = Vector2(j * X_DIST, i * -Y_DIST) + offset
			current_room.row = i
			current_room.column = j
			current_room.next_rooms = []
			
			
			if i == FLOORS - 1:
				current_room.position.y = (i + 1) * -Y_DIST
			
			adjacent_rooms.append(current_room)
		
		result.append(adjacent_rooms) 
	
	return result


func _get_random_starting_points() -> Array[int]:
	var y_coordinates: Array[int]
	var unique_points: int = 0
	
	while unique_points < 2:
		unique_points = 0
		y_coordinates = []
		
		for i in PATHS:
			var starting_point := randi_range(0, MAP_WIDTH - 1)
			if not y_coordinates.has(starting_point):
				unique_points += 1
			
			y_coordinates.append(starting_point)
		
	return y_coordinates


func _setup_connection(i: int, j: int) -> int:
	var next_room: Room
	var current_room := map_data[i][j] as Room
	
	while not next_room or _would_cross_existing_path(i, j, next_room):
		var random_j := clampi(randi_range(j - 1, j + 1), 0, MAP_WIDTH - 1)
		next_room = map_data[i + 1][random_j]
	
	current_room.next_rooms.append(next_room)
	
	return next_room.column


func _would_cross_existing_path(i: int, j: int, room: Room) -> bool:
	var left_neighbor: Room
	var right_neighbor: Room
	
	# if j == 0, there's no left neighbor
	if j > 0:
		left_neighbor = map_data[i][j - 1]
	# if j == MAP_WIDTH - 1, there's no right neighbor
	if j < MAP_WIDTH - 1:
		right_neighbor = map_data[i][j + 1]
	
	# checking if there's a right neighbor going left to determine if
	# we can cross that way
	if right_neighbor and room.column > j:
		for next_room: Room in right_neighbor.next_rooms:
			if next_room.column < room.column:
				return true
	
	# checking if there's a left neighbor going right to determine if
	# we can cross that way
	if left_neighbor and room.column < j:
		for next_room: Room in left_neighbor.next_rooms:
			if next_room.column > room.column:
				return true
	
	return false


func _setup_boss_room() -> void:
	var middle := floori(MAP_WIDTH * 0.5)
	var boss_room := map_data[FLOORS - 1][middle] as Room
	
	for j in MAP_WIDTH:
		var current_room = map_data[FLOORS - 2][j] as Room
		if current_room.next_rooms:
			current_room.next_rooms = [] as Array[Room]
			current_room.next_rooms.append(boss_room)
		
	boss_room.type = Room.Type.BOSS
	boss_room.battle_stats = battle_stats_pool.get_random_battle_for_tier(3)

func _setup_random_room_weights() -> void:
	random_room_type_weights[Room.Type.MONSTER] = MONSTER_ROOM_WEIGHT
	random_room_type_weights[Room.Type.CAMPFIRE] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT
	random_room_type_weights[Room.Type.SHOP] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT + SHOP_ROOM_WEIGHT
	random_room_type_weights[Room.Type.ELITE] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT + SHOP_ROOM_WEIGHT + ELITE_ROOM_WEIGHT
	random_room_type_weights[Room.Type.QUIZ_EVENT] = MONSTER_ROOM_WEIGHT + CAMPFIRE_ROOM_WEIGHT + SHOP_ROOM_WEIGHT + ELITE_ROOM_WEIGHT + QUIZ_EVENT_ROOM_WEIGHT
	
	random_room_type_total_weight = random_room_type_weights[Room.Type.QUIZ_EVENT]


func _setup_room_types() -> void:
	# first floor is always a battle
	for room: Room in map_data[0]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.MONSTER
			room.battle_stats = battle_stats_pool.get_random_battle_for_tier(0)
	
	# middle floor is always a treasure
	for room: Room in map_data[6]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.TREASURE
	
	# last floor before the boss is always a quiz event
	for room: Room in map_data[FLOORS - 2]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.QUIZ_EVENT
	
	# second last floor before the boss is always a rest area
	for room: Room in map_data[FLOORS - 3]:
		if room.next_rooms.size() > 0:
			room.type = Room.Type.CAMPFIRE
	
	# rest of the rooms
	for current_floor in map_data:
		for room: Room in current_floor:
			for next_room: Room in room.next_rooms:
				if next_room.type == Room.Type.NOT_ASSIGNED:
					_set_room_randomly(next_room)


func _set_room_randomly(room_to_set: Room) -> void:
	var campfire_below_6 := true
	var elite_below_6 := true
	var consecutive_campfire := true
	var consecutive_shop := true
	var consecutive_elite := true
	var campfire_below_event_boss := true
	var shop_below_3 := true
	
	var type_candidate: Room.Type
	
	while campfire_below_6 or elite_below_6 or consecutive_campfire or consecutive_shop or consecutive_elite or campfire_below_event_boss or shop_below_3:
		type_candidate = _get_random_room_type_by_weight()
		
		var is_campfire := type_candidate == Room.Type.CAMPFIRE
		var has_campfire_parent := _room_has_parent_of_type(room_to_set, Room.Type.CAMPFIRE)
		var is_shop := type_candidate == Room.Type.SHOP
		var has_shop_parent := _room_has_parent_of_type(room_to_set, Room.Type.SHOP)
		var is_elite := type_candidate == Room.Type.ELITE
		var has_elite_parent := _room_has_parent_of_type(room_to_set, Room.Type.ELITE)
		
		campfire_below_6 = is_campfire and room_to_set.row < 5
		elite_below_6 = is_elite and room_to_set.row < 5
		shop_below_3 = is_shop and room_to_set.row < 2
		consecutive_campfire = is_campfire and has_campfire_parent
		consecutive_shop = is_shop and has_shop_parent
		consecutive_elite = is_elite and has_elite_parent
		campfire_below_event_boss = is_campfire and room_to_set.row == FLOORS - 2

	room_to_set.type = type_candidate
	
	if type_candidate == Room.Type.ELITE:
		room_to_set.battle_stats = battle_stats_pool.get_random_battle_for_tier(2)
	
	if type_candidate == Room.Type.MONSTER:
		var tier_for_monster_rooms := 0
	
		if room_to_set.row > 3:
			tier_for_monster_rooms = 1
		
		room_to_set.battle_stats = battle_stats_pool.get_random_battle_for_tier(tier_for_monster_rooms)

func _room_has_parent_of_type(room: Room, type: Room.Type) -> bool:
	var parents: Array[Room] = []
	# left parent
	if room.column > 0 and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column - 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# below parent
	if room.column > 0:
		var parent_candidate := map_data[room.row - 1][room.column] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	# right parent
	if room.column < MAP_WIDTH - 1  and room.row > 0:
		var parent_candidate := map_data[room.row - 1][room.column + 1] as Room
		if parent_candidate.next_rooms.has(room):
			parents.append(parent_candidate)
	
	for parent: Room in parents:
		if parent.type == type:
			return true
	
	return false


func _get_random_room_type_by_weight() -> Room.Type: 
	var roll := randf_range(0.0, random_room_type_total_weight)
	
	for type: Room.Type in random_room_type_weights:
		if random_room_type_weights[type] > roll:
			return type
	
	return Room.Type.MONSTER
