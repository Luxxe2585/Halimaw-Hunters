extends Control

const RUN_SCENE := preload("res://Scenes/run/run.tscn")
const KUDAMAN_STATS := preload("res://characters/warrior/warrior.tres")
const DATU_STATS := preload("res://characters/datuputi/datuputi.tres")
const BROTHERS_STATS := preload("res://characters/brothers/brothers.tres")

@export var run_startup: RunStartup

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPortrait

var current_character: CharacterStats : set = set_current_character


func _ready() -> void:
	set_current_character(KUDAMAN_STATS)


func set_current_character(new_character: CharacterStats) -> void:
	current_character = new_character
	title.text = current_character.character_name
	description.text = current_character.description
	character_portrait.texture = current_character.portrait

func _on_start_button_pressed() -> void:
	print("Start new run with %s" % current_character.character_name)
	run_startup.type = RunStartup.Type.NEW_RUN
	run_startup.picked_character = current_character
	get_tree().change_scene_to_packed(RUN_SCENE)


func _on_kudaman_button_pressed() -> void:
	current_character = KUDAMAN_STATS


func _on_datu_puti_button_pressed() -> void:
	current_character = DATU_STATS

func _on_brothers_button_pressed() -> void:
	current_character = BROTHERS_STATS
