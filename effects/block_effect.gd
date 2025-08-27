class_name BlockEffect
extends Effect

var amount:= 0
var receiver_modifier_type := Modifier.Type.BLOCK_GAINED


func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		
		if target is Enemy or target is Player:
			var modified_amount = amount
			if target.has_method("get_modified_block_gain"):
				modified_amount = target.get_modified_block_gain(amount)
			
			target.stats.block += modified_amount
			SFXPlayer.play(sound)
