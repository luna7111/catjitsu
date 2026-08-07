extends CanvasLayer


signal multiplayer_pressed
signal singleplayer_pressed
signal profile_pressed
signal settings_pressed


func _ready() -> void:
	get_tree().current_scene.input_mode_changed.connect(_on_input_mode_changed)
	if visible and Global.current_input_mode != Global.InputMode.MOUSE:
		$Dummy.grab_focus()
	if (Global.logged_in == false):
		$PanelContainer/MarginContainer/Buttons/Multiplayer.hide()
	else:
		$PanelContainer/MarginContainer/Buttons/Multiplayer.show()


func _on_multiplayer_pressed() -> void:
	emit_signal("multiplayer_pressed")


func _on_singleplayer_pressed() -> void:
	emit_signal("singleplayer_pressed")


func _on_settings_pressed() -> void:
	emit_signal("settings_pressed")


func _on_profile_pressed() -> void:
	emit_signal("profile_pressed")


func _on_input_mode_changed(mode: Variant, previous: Variant) -> void:
	print ("input_mode_changed")
	if not visible:
		return
	match mode:
		Global.InputMode.MOUSE:
			print("mouse")
			if (previous != Global.InputMode.MOUSE):
				$Dummy.grab_focus()
				$Dummy.release_focus()
		Global.InputMode.KEYBOARD:
			print("keyboard")
			if (previous == Global.InputMode.MOUSE):
				$Dummy.grab_focus()
		Global.InputMode.CONTOLLER:
			print("Controller")
			if (previous == Global.InputMode.MOUSE):
				$Dummy.grab_focus()


func _on_visibility_changed() -> void:
	if (Global.logged_in == false):
		$PanelContainer/MarginContainer/Buttons/Multiplayer.hide()
	else:
		$PanelContainer/MarginContainer/Buttons/Multiplayer.show()
	if visible and Global.current_input_mode != Global.InputMode.MOUSE:
		$Dummy.grab_focus()


func _on_tree_entered() -> void:
	if (Global.logged_in == false):
		$PanelContainer/MarginContainer/Buttons/Multiplayer.hide()
	else:
		$PanelContainer/MarginContainer/Buttons/Multiplayer.show()


func _on_singleplayer_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($PanelContainer/MarginContainer/Buttons/Singleplayer.text), Global.tts_voice)


func _on_multiplayer_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($PanelContainer/MarginContainer/Buttons/Multiplayer.text), Global.tts_voice)


func _on_profile_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($PanelContainer/MarginContainer/Buttons/Profile.text), Global.tts_voice)


func _on_settings_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($PanelContainer/MarginContainer/Buttons/Settings.text), Global.tts_voice)
