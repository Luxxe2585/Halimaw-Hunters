class_name Map
extends Node2D

const SCROLL_SPEED := 15
const KEYBOARD_SCROLL_SPEED := 200
const MAP_ROOM = preload("res://Scenes/map/map_room.tscn")
const MAP_LINE = preload("res://Scenes/map/map_line.tscn")

@onready var map_generator: MapGenerator = $MapGenerator
@onready var lines: Node2D = %Lines
@onready var rooms: Node2D = %Rooms
@onready var visuals: Node2D = $Visuals
@onready var camera_2d: Camera2D = $Camera2D

var map_data: Array[Array]
var floors_climbed: int
var last_room: Room
var camera_edge_y: float

var initial_camera_position: float
var scroll_tween: Tween



func _ready() -> void:
	camera_edge_y = MapGenerator.Y_DIST * (MapGenerator.FLOORS - 1)
	initial_camera_position = -camera_edge_y  # Top of the map
	camera_2d.position.y = initial_camera_position
	_clamp_camera_position()  # Ensure initial position is clamped


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	
	# Handle discrete scroll wheel events
	if event.is_action_pressed("scroll_up"):
		camera_2d.position.y -= SCROLL_SPEED
		_clamp_camera_position()
	elif event.is_action_pressed("scroll_down"):
		camera_2d.position.y += SCROLL_SPEED
		_clamp_camera_position()


func _process(delta: float) -> void:
	if not visible:
		return
	
	# Handle continuous keyboard scrolling
	var scroll_direction := 0
	if Input.is_action_pressed("direction_key_up"):
		scroll_direction -= 1
	if Input.is_action_pressed("direction_key_down"):
		scroll_direction += 1
	
	if scroll_direction != 0:
		camera_2d.position.y += scroll_direction * KEYBOARD_SCROLL_SPEED * delta
		_clamp_camera_position()


# New helper function to clamp camera position
func _clamp_camera_position() -> void:
	camera_2d.position.y = clamp(camera_2d.position.y, -camera_edge_y, 0)


func animate_camera_scroll(pause_time: float, scroll_duration: float) -> void:
	# Create tween for smooth animation
	if scroll_tween:
		scroll_tween.kill()
	
	scroll_tween = create_tween()
	scroll_tween.tween_interval(pause_time)
	scroll_tween.tween_property(camera_2d, "position:y", 0.0, scroll_duration)
	scroll_tween.set_ease(Tween.EASE_OUT)
	scroll_tween.set_trans(Tween.TRANS_SINE)


func generate_new_map() -> void:
	floors_climbed = 0
	map_data = map_generator.generate_map()
	create_map()


func load_map(map: Array[Array], floors_completed: int, last_room_climbed: Room) -> void:
	floors_climbed = floors_completed
	map_data = map
	last_room = last_room_climbed
	create_map()
	
	if floors_climbed > 0:
		unlock_next_rooms()
	else:
		unlock_floor()


func create_map() -> void:
	for current_floor: Array in map_data:
		for room: Room in current_floor:
			if room.next_rooms.size() > 0 :
				_spawn_room(room)
	
	# Boss room has no next room but it still needs to be spawned
	var middle := floori(MapGenerator.MAP_WIDTH * 0.5)
	_spawn_room(map_data[MapGenerator.FLOORS-1][middle])

	var map_width_pixels := MapGenerator.X_DIST * (MapGenerator.MAP_WIDTH - 1)
	visuals.position.x = (get_viewport_rect().size.x - map_width_pixels) / 2
	visuals.position.y = get_viewport_rect().size.y / 2


func clear_map() -> void:
	# Clear all rooms and lines
	for child in rooms.get_children():
		child.queue_free()
	for child in lines.get_children():
		child.queue_free()
	
	# Reset map state
	last_room = null
	floors_climbed = 0


func unlock_floor(which_floor: int = floors_climbed) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == which_floor:
			map_room.available = true


func unlock_next_rooms() -> void:
	for map_room: MapRoom in rooms.get_children():
		if last_room.next_rooms.has(map_room.room):
			map_room.available = true


func show_map() -> void:
	show()
	camera_2d.enabled = true


func hide_map() -> void:
	hide()
	camera_2d.enabled = false
	

func _spawn_room(room: Room) -> void:
	var new_map_room := MAP_ROOM.instantiate() as MapRoom
	rooms.add_child(new_map_room)
	new_map_room.room = room
	new_map_room.clicked.connect(_on_map_room_clicked)
	new_map_room.selected.connect(_on_map_room_selected)
	_connect_lines(room)
	
	if room.selected and room.row < floors_climbed:
		new_map_room.show_selected()


func _connect_lines(room: Room) -> void:
	if room.next_rooms.is_empty():
		return
	
	for next: Room in room.next_rooms:
		var new_map_line := MAP_LINE.instantiate() as Line2D
		new_map_line.add_point(room.position)
		new_map_line.add_point(next.position)
		lines.add_child(new_map_line)


func _on_map_room_clicked(room: Room) -> void:
	for map_room: MapRoom in rooms.get_children():
		if map_room.room.row == room.row:
			map_room.available = false


func _on_map_room_selected(room: Room) -> void:
	last_room = room
	floors_climbed += 1
	Events.map_exited.emit(room)
