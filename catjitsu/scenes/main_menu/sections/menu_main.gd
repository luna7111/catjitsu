extends CanvasLayer


signal multiplayer_pressed
signal singleplayer_pressed
signal profile_pressed
signal settings_pressed


func _on_multiplayer_pressed() -> void:
	emit_signal("multiplayer_pressed")


func _on_singleplayer_pressed() -> void:
	emit_signal("singleplayer_pressed")


func _on_settings_pressed() -> void:
	emit_signal("settings_pressed")


func _on_profile_pressed() -> void:
	emit_signal("profile_pressed")
