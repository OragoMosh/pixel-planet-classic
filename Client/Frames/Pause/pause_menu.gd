extends GUIBase



#Node Imports
@onready var resumeButton = $ResumeButton
@onready var settingsButton = $SettingsButton
@onready var respawnButton = $RespawnButton
@onready var claimPlanetButton = $ClaimPlanetButton
@onready var planetMenu = $PlanetMenu
@onready var marketplace = $Marketplace
@onready var shop = $Shop
@onready var leavePlanet = $LeavePlanet
@onready var favoriteButton = $FavoriteButton



func _ready():
	if Global.LastVisitedPlanet == Save.userData.Misc.FavoritePlanet and Global.LastVisitedPlanet != "":
		favoriteButton.button_pressed = true
	else:
		favoriteButton.button_pressed = false


func OnOpen() -> void:
	claimPlanetButton.disabled = not Global.WorldData.OwnerId == -1
	$WorldInfoLabel.text = "You and " + str(Global.PeersNode.get_child_count()) + " Others are currently in " + Global.WorldData.Name.to_upper()
	
	if Global.WorldData.OwnerName == "":
		$WorldInfoLabel.text += "\nThis planet is unclaimed"
	else:
		$WorldInfoLabel.text += "\nThis planet is claimed by " + Global.WorldData.OwnerName


func _on_resume_button_pressed():
	Global.WorldNode.WorldGUIManager.CloseGui()

func _on_settings_button_pressed():
	Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.Settings)


func _on_respawn_button_pressed():
	if Global.PlayerNode.is_dead == false:
		Global.PlayerNode.Die()
		Global.WorldNode.WorldGUIManager.CloseGui()



func _on_claim_planet_button_pressed():
	Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.ClaimPlanet)



func _on_planet_menu_pressed():
	pass # Replace with function body.



func _on_marketplace_pressed():
	Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.Marketplace)



func _on_shop_pressed():
	Global.WorldNode.WorldGUIManager.ChangeGui(Global.WorldNode.Shop)



func _on_leave_planet_pressed():
	Server.WorldLeaveRequest()



func _on_texture_button_pressed():
	if favoriteButton.button_pressed == true:
		Save.userData.Misc.FavoritePlanet = Global.LastVisitedPlanet
	else:
		Save.userData.Misc.FavoritePlanet = ""
	


func _on_mod_menu_button_pressed():
	pass # Replace with function body.
