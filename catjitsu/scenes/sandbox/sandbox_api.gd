extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_get_players_button_pressed() -> void:
	print("get players button pressed")
	$Node/HTTPRequest.request_completed.connect(_print_json)
	$Node/HTTPRequest.request("http://127.0.0.1:8000/players")

func _print_json(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)


func _on_get_player_button_pressed() -> void:
	#var to_send = ["name"]
	# json["name"] = $Node/MarginContainer/HBoxContainer/GetPlayerMenu/HBoxContainer/GetPlayerName.text
	pass


func _on_post_player_button_pressed() -> void:
	print("post player button pressed")
	var player_name = $MarginContainer/TabContainer/Players/VBoxContainer2/HBoxContainer/PostPlayerName.text
	var headers = ["Content-Type: application/json"]
	$Node/HTTPRequest.request("http://127.0.0.1:8000/players/	", headers, HTTPClient.METHOD_POST, "{\"name\": \"" + player_name + "\"}")


func _on_back_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/sandbox/sandbox_menu.tscn", false)
