extends Node

var visible_chrs = 0

var cutscene_over = false

@onready var disclaimer: PackedScene = load("res://Frames/Disclaimer/Disclaimer.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	
	if $Label.visible_characters != visible_chrs:
		visible_chrs = $Label.visible_characters
		if not $TypeSFX.playing:
			$TypeSFX.play()
			$TypeSFX.pitch_scale = randf_range(1, 1.5)
	
	if cutscene_over:
		pass
	
	
	if $AnimationPlayer.current_animation_position >= 7.0:
		$HornSFX.pitch_scale = 1.5
	else:
		$HornSFX.pitch_scale = 1.0

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Start":
		cutscene_over = true
		
		Save.userData["Settings"]["SeenCutscene"] = true
		
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$AnimationPlayer.play("Label")
		$EndCutscene.start(20)
	
	elif anim_name == "Finish":
		if not Save.userData["Settings"]["DisclaimerAgreement"]:
			get_tree().change_scene_to_packed(disclaimer)

func _input(event):
	if cutscene_over:
		if event is InputEventMouseMotion:
			return
		else:
			cutscene_over = false
			$AnimationPlayer.play("Finish")
			print("finish")


func _on_end_cutscene_timeout():
	cutscene_over = false
	$AnimationPlayer.play("Finish")
