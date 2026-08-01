extends CanvasLayer


signal back_pressed


func _on_back_button_pressed() -> void:
	emit_signal("back_pressed")
