extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Settings.hide()
	$Multiplayer.hide()
	$Profile.hide()
	$Main.show()
	pass


func _on_sofa_arrival() -> void:
	$Settings.show()


func _on_cat_arrival() -> void:
	$Main.show()
	$SubViewportContainer/SubViewport/MainMenuBackground.play_idle()


func _on_tv_arrival() -> void:
	$Multiplayer.show()


func _on_main_menu_background_table_arrival() -> void:
	$Profile.show()


func _on_main_settings_pressed() -> void:
	$Main.hide()
	$SubViewportContainer/SubViewport/MainMenuBackground.switch_to_sofa()


func _on_main_profile_pressed() -> void:
	$Main.hide()
	$SubViewportContainer/SubViewport/MainMenuBackground.switch_to_table()


func _on_settings_back_pressed() -> void:
	$Settings.hide()
	$SubViewportContainer/SubViewport/MainMenuBackground.sofa_switch_to_cat()


func _on_main_multiplayer_pressed() -> void:
	$Main.hide()
	$SubViewportContainer/SubViewport/MainMenuBackground.switch_to_tv()



func _on_main_singleplayer_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/singleplayer/singleplayer_main.tscn", true)


func _on_profile_back_pressed() -> void:
	$Profile.hide()
	$SubViewportContainer/SubViewport/MainMenuBackground.table_switch_to_cat()


func _on_multiplayer_back_pressed() -> void:
	$Multiplayer.hide()
	$SubViewportContainer/SubViewport/MainMenuBackground.tv_switch_to_cat()
