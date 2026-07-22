extends CanvasLayer


signal back_pressed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
