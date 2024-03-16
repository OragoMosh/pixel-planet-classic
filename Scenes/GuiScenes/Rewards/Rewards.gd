extends GUIBase

@onready var BuyAgainButton = $BuyAgain

var current_pack_id: String


func ShowRewards(items_unpacked):
	
	for reward_slot in $HBoxContainer.get_children():
		reward_slot.queue_free()
	
	print(items_unpacked)
	for item in items_unpacked:
		var rewardSlot = load("res://Scenes/GuiScenes/Rewards/RewardSlot.tscn").instantiate()
		rewardSlot.setup(item[0], item[1])
		
		$HBoxContainer.add_child(rewardSlot)


func _on_show_all_pressed() -> void:
	for reward_slot in $HBoxContainer.get_children():
		reward_slot.Reveal()


func _on_close_pressed() -> void:
	Global.WorldNode.WorldGUIManager.CloseGui()


func _on_buy_again_pressed() -> void:
	Server.ShopPurchaseRequest(Global.WorldNode.Rewards.current_pack_id)
