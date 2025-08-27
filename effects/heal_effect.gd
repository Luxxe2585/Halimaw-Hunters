class_name HealEffect
extends Effect

var amount := 0
const music = preload("res://assets/sfx/healing-magic.mp3") 

func execute(targets: Array[Node]) -> void:
	for target in targets:
		if not target:
			continue
		if target is Enemy or target is Player:
			target.stats.heal(amount)
			sound = music
			SFXPlayer.play(sound)
