class_name CurseCard
extends Card

func _init() -> void:
	type = Type.CURSE
	unplayable = true
	cost = 99
	target = Target.SELF
