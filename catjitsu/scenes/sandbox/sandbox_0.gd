extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)


func _on_gui_sandbox_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/sandbox/sandbox_gui.tscn", false)


func _on_api_sandbox_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/sandbox/sandbox_api.tscn", false)
