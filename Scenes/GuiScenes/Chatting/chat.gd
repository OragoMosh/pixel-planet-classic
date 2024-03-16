extends GUIBase



func _ready():
	Global.ChatNode = self

func incomingMessage(nickname, message):
	$Messages.text += "\n" + "<" + nickname + "> " + message


#func OnOpen() -> void:
	#if not $ChatInput.has_focus():
		#$ChatInput.grab_focus()


func _input(event):
	if Input.is_action_just_pressed("Chat"):
		if not $ChatInput.has_focus():
			$ChatInput.grab_focus()
		
		if $ChatInput.has_focus() and len($ChatInput.text) != 0:
			
			Server.rpc_id(1, "MessageRequest", $ChatInput.text)
			
			Global.WorldNode.WorldGUIManager.CloseGui()
			$ChatInput.release_focus()
			$ChatInput.clear()
		


func OnClose() -> void:
	$ChatInput.release_focus()
	Global.WorldNode.WorldGUIManager.typing = false
