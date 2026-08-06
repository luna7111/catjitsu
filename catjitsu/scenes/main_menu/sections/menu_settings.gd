extends CanvasLayer


signal back_pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.settings_changed.connect(_update_settings)
	get_tree().current_scene.input_mode_changed.connect(_on_input_mode_changed)
	
	$HTTP/UpdatePreferences.request_completed.connect(_on_preferences_request_completed)
	
	match  Global.config.language:
		"English":
			$MarginContainer/Buttons/LanguageMenu/LanguageOptions.select(0)
		"Spanish":
			$MarginContainer/Buttons/LanguageMenu/LanguageOptions.select(1)
		"French":
			$MarginContainer/Buttons/LanguageMenu/LanguageOptions.select(2)


func _update_settings():
	$MarginContainer/Buttons/VolumeMenu/VolumeSlider.value = Global.config.volume
	print("settings ready volumes " ,$MarginContainer/Buttons/VolumeMenu/VolumeSlider.value, Global.config.volume)


func _on_back_button_pressed() -> void:
	emit_signal("back_pressed")


func _on_apply_button_pressed() -> void:
	match $MarginContainer/Buttons/LanguageMenu/LanguageOptions.get_selected_id():
		0:
			Global.config.language = "English"
		1:
			Global.config.language = "Spanish"
		2:
			Global.config.language = "French"
	Global.config.volume = $MarginContainer/Buttons/VolumeMenu/VolumeSlider.value
	print("Volume is ", Global.config.volume)
	Global.settings_changed.emit()
	Global.update_config()

	# send preferences to server with default values (English, screenreader=0)
	var url = "http://localhost:8000/player/" + str(Global.profile.id).pad_decimals(0) + "/preferences"
	var headers = ["Content-Type: application/json"]
	if Global.api.access_token != "":
		headers.append("Authorization: Bearer " + Global.api.access_token)
	var body = "{\"language\": \"" + Global.config.language + "\", \"screenreader\": 0, \"volume\": " + str(Global.config.volume) + "}"
	if Global.logged_in:
		$HTTP/UpdatePreferences.request(url, headers, HTTPClient.METHOD_PUT, body)

func _on_preferences_request_completed(result, response_code, headers, body):
	print("preferences update response:")
	print(response_code)
	var pr = JSON.parse_string(body.get_string_from_utf8())
	if typeof(pr) == TYPE_DICTIONARY:
		print(pr)
	elif pr.error == OK:
		print(pr.result)
	else:
		print("could not parse response")


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
	if visible and Global.current_input_mode != Global.InputMode.MOUSE:
		$Dummy.grab_focus()
