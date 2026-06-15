extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_dummy_scene_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/sandbox/dummy_scene.tscn", false)



func _on_api_sandbox_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/sandbox/sandbox_api.tscn", false)
