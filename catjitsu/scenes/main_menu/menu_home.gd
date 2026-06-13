extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_settings_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/main_menu/menu_settings.tscn", true)
	pass # Replace with function body.
