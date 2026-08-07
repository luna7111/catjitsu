extends CanvasLayer


signal back_pressed

var screenreader_pressed = int(Global.config.screenreader)

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
	
	$MarginContainer/Buttons/ScreenReaderMenu/CheckButton.set_pressed_no_signal(Global.config.screenreader)


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
	
	Global.config.screenreader = screenreader_pressed
	print ("SCREENREADER IS ", Global.config.screenreader)
	Global.update_voices()
	
	Global.settings_changed.emit()
	Global.update_config()
	
	var url = Global.api_host + "/player/" + str(Global.profile.id).pad_decimals(0) + "/preferences"
	var token = Global.token
	var headers = ["Content-Type: application/json", "Authorization: Token " + token]
	var screenreader: int = screenreader_pressed
	var body = "{\"language\": \"" + Global.config.language + "\", \"screenreader\": " + str(screenreader_pressed) + ", \"volume\": " + str(Global.config.volume) + "}"
	print(body)
	if Global.logged_in and Global.api_working:
		print("LIAW")
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


func _on_language_options_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/Buttons/LanguageMenu/LanguageTag.text), Global.tts_voice)


func _on_check_button_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/Buttons/ScreenReaderMenu/ScreenreaderTag.text), Global.tts_voice)



func _on_volume_slider_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/Buttons/VolumeMenu/VolumeTag.text), Global.tts_voice)


func _on_apply_button_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/Buttons/ApplyButton.text), Global.tts_voice)


func _on_back_button_focus_entered() -> void:
	print (Global.config.screenreader)
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/Buttons/BackButton.text), Global.tts_voice)


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		print("ON")
		screenreader_pressed = 1
	else:
		print("OFF")
		screenreader_pressed = 0
