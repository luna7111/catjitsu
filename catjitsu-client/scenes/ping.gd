extends HTTPRequest


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	request_completed.connect(_ping)
	while (1):
		request(Global.api_host + "/ping/")
		await get_tree().create_timer(2).timeout



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _ping(result, response_code, headers, body):
	if Global.api_working == false and response_code != 0:
		Global.scene_manager.emit_signal("api_up")
		Global.api_working = true
	if Global.api_working == true and response_code == 0:
		Global.scene_manager.emit_signal("api_down")
		Global.api_working = false
