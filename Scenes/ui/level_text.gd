# ActText.gd
class_name ActText
extends Container

@onready var title_text: RichTextLabel = %TitleText
@onready var animation_player: AnimationPlayer = %ActTextAnimation


func update_act_text(level: int) -> void:
	var act_name := ""
	match level:
		1:
			act_name = "ACT I: THE FOREST"
		2:
			act_name = "ACT II: THE ISLANDS"
		3:
			act_name = "ACT III: THE DARK MOUNTAIN"
		4:
			act_name = "SARAGNAYAN'S CASTLE"
	
	title_text.text = title_text.text % act_name

func play_act_animation() -> void:
	print("ActText visibility before show(): ", visible)
	show()
	print("ActText visibility after show(): ", visible)
	
	if is_inside_tree():
		print("ActText is in scene tree")
	else:
		print("WARNING: ActText not in scene tree")
	
	if animation_player.is_playing():
		animation_player.stop()
	
	# Debug animation player
	if animation_player:
		print("AnimationPlayer found: ", animation_player.name)
		if animation_player.has_animation("FADE"):
			print("FADE animation found")
			animation_player.play("FADE")
			print("Animation play called")
		else:
			print("ERROR: FADE animation not found in AnimationPlayer")
	else:
		print("ERROR: AnimationPlayer not found")
	
	if animation_player:
		# Create a simple test animation
		var test_anim = Animation.new()
		var track_idx = test_anim.add_track(Animation.TYPE_VALUE)
		test_anim.track_set_path(track_idx, ".:modulate")
		test_anim.track_insert_key(track_idx, 0.0, Color(1,1,1,0))
		test_anim.track_insert_key(track_idx, 1.0, Color(1,1,1,1))
		test_anim.length = 1.0
		
		animation_player.play("TEST")
		print("Playing TEST animation")
	
	if animation_player:
		animation_player.play("FADE")
		# Force immediate update
		animation_player.advance(0)
		get_tree().process_frame
	
