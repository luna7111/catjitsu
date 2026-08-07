extends HBoxContainer

var options: = []
var selected = 0
var item_count = 0

signal selection_changed


func _process(delta: float) -> void:
	if has_focus():
		if Input.is_action_just_pressed("ui_left"):
			_on_previous_pressed()
		elif Input.is_action_just_pressed("ui_right"):
			_on_next_pressed()


func add_item(item: String):
	options.append(item)
	item_count += 1


func get_item_text(id: int) -> String:
	if id >= 0 and id < item_count:
		return options[id]
	else:
		return ""


func select(id: int):
	if id >= 0 and id < item_count:
		selected = id
	update_text()


func update_text():
	if item_count > 0:
		$Display.text = options[selected]


func _on_previous_pressed() -> void:
	selected -= 1
	if selected < 0:
		selected = item_count - 1
	update_text()
	selection_changed.emit()
	if DisplayServer.accessibility_screen_reader_active():
		DisplayServer.tts_speak(TranslationServer.tr($Display.text), Global.tts_voice)


func _on_next_pressed() -> void:
	selected += 1
	if selected >= item_count:
		selected = 0
	update_text()
	selection_changed.emit()
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($Display.text), Global.tts_voice)


func _on_focus_entered() -> void:
	$Previous.add_theme_color_override("font_color", "bc2851")
	$Next.add_theme_color_override("font_color", "bc2851")
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($Display.text), Global.tts_voice)



func _on_focus_exited() -> void:
	$Previous.add_theme_color_override("font_color", "fafafa")
	$Next.add_theme_color_override("font_color", "fafafa")
