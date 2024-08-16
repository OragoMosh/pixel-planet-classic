extends Control

@onready var recent_planet_button = $Tabs/PlanetTab/RecentPlanetButton
@onready var favorite_planet_button = $Tabs/PlanetTab/FavoritePlanetButton
@onready var login_status_label = $LoginStatusLabel
@onready var world_name_edit = $Tabs/PlanetTab/WorldNameEdit
@onready var planet_tab = $Tabs/PlanetTab
@onready var settings_tab = $Tabs/SettingsTab
@onready var popup := $Popup

func _ready():
	login_status_label.text = "Logged in as: " + Global.Username
	if Global.LastVisitedPlanet != "":
		recent_planet_button.disabled = false
		recent_planet_button.text = "Recent Planet: " + Global.LastVisitedPlanet.to_upper()
	if Save.userData.Misc.FavoritePlanet != "":
		favorite_planet_button.disabled = false
		favorite_planet_button.text = "Favorite Planet: " + Save.userData.Misc.FavoritePlanet.to_upper()


#func _on_enter_world_button_pressed():
	#Server.WorldJoinRequest(world_name_edit.text)


func _on_recent_planet_button_pressed() -> void:
	Server.WorldJoinRequest(Global.LastVisitedPlanet)



func _on_favorite_planet_button_pressed():
	Server.WorldJoinRequest(Save.userData.Misc.FavoritePlanet)



func _on_hub_button_pressed() -> void:
	Server.WorldJoinRequest("hub")



func _on_world_name_edit_text_changed(new_text: String) -> void:
	$Tabs/PlanetTab/EnterWorldButton2.disabled = not len(new_text) > 0

func _on_planets_button_pressed():
	resetUI()
	planet_tab.visible = true

func _on_settings_button_pressed():
	resetUI()
	settings_tab.visible = true


func resetUI():
	for tab in $Tabs.get_children():
		tab.visible = false





func _on_fullscreen_toggle_toggled(toggled_on):

	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		Save.userData.Settings.Fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		Save.userData.Settings.Fullscreen = false



func _on_enter_world_button_2_pressed() -> void:
	Server.WorldJoinRequest(world_name_edit.text)



func _on_audio_stream_player_finished() -> void:
	$AudioStreamPlayer.play()
