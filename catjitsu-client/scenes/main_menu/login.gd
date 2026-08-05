extends Control


var client_authorised = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Login42Panel.hide()
	$LoginOptions.show()
	set_process(false)


func wait_for_request(auth_client: StreamPeerTCP) -> String:
	while auth_client.get_available_bytes() == 0:
		await get_tree().create_timer(2).timeout
	var request = auth_client.get_utf8_string(auth_client.get_available_bytes())
	return request


func parse_auth_code_from_request(request: String) -> String:
	var first_line = request.split("\r\n")[0]
	print("request first line: " + first_line)
	var path = first_line.split(" ")[1]
	print("GET path:" + path)
	var query = path.split("?")[1]
	var params = {}
	for pair in query.split("&"):
		var key_value = pair.split("=")
		if key_value.size() == 2:
			params[key_value[0]] = key_value[1]
		
	print("code: " + params["code"])
	return params["code"]


func _on_skip_login_pressed() -> void:
	Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)


func _on_login_intra_pressed() -> void:
	var exchange_uuid = UUID.v4()
	var query_param = "?exchange_uuid=" + exchange_uuid
	print(exchange_uuid)
	OS.shell_open("http://localhost:8000/auth/42/login/" + query_param)
	$LoginOptions.hide()
	$Login42Panel.show()
	request_tokens(query_param)


func request_tokens(query_param):
	$HTTPRequest.request_completed.connect(_uuid_sent)
	while ($Login42Panel.visible and client_authorised == false):
		$HTTPRequest.request("http://localhost:8000/identify-client/" + query_param)
		await get_tree().create_timer(2.0).timeout


func _uuid_sent(_result, response_code, _headers, body):
	if not response_code == 200:
		print("Didn't reveive tokens yet")
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	print (response_code)
	if json == null:
		print("Didn't receive tokens yet")
	else:
		client_authorised = true
		print (json)
		var access_token = json["access"]
		var refresh_token = json["refresh"]
		Global.api.access_token = access_token
		Global.api.refresh_token = refresh_token
		var nickname = json["nickname"]
		_request_player_data(nickname)
		Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)


func _request_player_data(nickname: String):
	$HTTPRequest.request_completed.connect(_fetch_player_data)
	$HTTPRequest.request("http://localhost:8080/player/ldel-val")

func _fetch_player_data(result, response_code, headers, body):
	if response_code != 200:
		print("Server didn't answer")
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		print ("player json: " + json)
	else:
		print ("player doesnt exist")


func _on_login42_back_button_pressed() -> void:
	$Login42Panel.hide()
	$LoginOptions.show()
