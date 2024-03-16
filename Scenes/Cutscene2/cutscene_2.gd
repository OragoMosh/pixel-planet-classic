extends Node2D

var visible_chrs = 0

func _process(delta):
	if $CanvasLayer/OpeningDialogue/Text.visible_characters != visible_chrs:
		visible_chrs = $CanvasLayer/OpeningDialogue/Text.visible_characters
		if not $TypeSFX.playing:
			$TypeSFX.play()
			$TypeSFX.pitch_scale = randf_range(1, 1.5)
	
	if $AnimationPlayer.current_animation_position >= 21.0:
		$SpiderverseTypeShit.pitch_scale = 0.9
	else:
		$SpiderverseTypeShit.pitch_scale = 1.5

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	$CanvasLayer/OpeningDialogue/Text.text = "Listen up, " + $Stellarian/Username.text + "\nWeird things are coming. Faces, voices—maybe yours. Don't trust any of them.. Watch your back. Stay sharp.\n-Silent Guardian"


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Cutscene":
		get_tree().change_scene_to_file("res://Scenes/Cutscene/cutscene.tscn")
