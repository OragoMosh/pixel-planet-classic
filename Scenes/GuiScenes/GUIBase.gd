class_name GUIBase extends Control

signal opened

var open: bool = false
var can_open: bool = true

func Toggle():
	if self.can_open == false: return
	
	if self.open == true:
		Global.WorldNode.GUIRect.visible = false
		self.can_open = false
		if has_method("OnClose"):
			call("OnClose")
		
		$AnimationPlayer.play("close")
		await $AnimationPlayer.animation_finished
		visible = false
		self.can_open = true
		
	else:
		Global.WorldNode.GUIRect.visible = true
		visible = true
		self.can_open = false
		if has_method("OnOpen"):
			call("OnOpen")
		
		$AnimationPlayer.play("open")
		await $AnimationPlayer.animation_finished
		self.can_open = true
		opened.emit()
	
	self.open = not self.open
