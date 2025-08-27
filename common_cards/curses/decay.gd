class_name DecayCurse
extends CurseCard


func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var damage_effect := DamageEffect.new()
	damage_effect.amount = 2  
	damage_effect.receiver_modifier_type = Modifier.Type.NO_MODIFIER  
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
