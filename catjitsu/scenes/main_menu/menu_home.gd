extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Settings.hide()
	$Multiplayer.hide()
	$Profile.hide()
	$Main.show()
	pass #$CanvasLayer/AnimationPlayer.play("CardsIn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_sofa_arrival() -> void:
	$Settings.show()


func _on_cat_arrival() -> void:
	$Main.show()


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
	Global.scene_manager.switch_scene("res://scenes/singleplayer/singleplayer_main.tscn", false)
