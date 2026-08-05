extends CanvasLayer


signal back_pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().current_scene.input_mode_changed.connect(_on_input_mode_changed)
	
	match  Global.config.language:
		"English":
			$MarginContainer/Buttons/LanguageMenu/LanguageOptions.select(0)
		"Spanish":
			$MarginContainer/Buttons/LanguageMenu/LanguageOptions.select(1)
		"French":
			$MarginContainer/Buttons/LanguageMenu/LanguageOptions.select(2)


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
	Global.update_config()


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
