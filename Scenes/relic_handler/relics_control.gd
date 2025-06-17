class_name RelicsControl
extends Control

@onready var relics: HBoxContainer = %Relics

var num_of_relics := 0


func _ready() -> void:
	for relic_ui: RelicUI in relics.get_children():
		relic_ui.free()
	
	relics.child_order_changed.connect(_on_relics_child_order_changed)


func update() -> void:
	num_of_relics = relics.get_child_count()


func _on_relics_child_order_changed() -> void:
	update()
