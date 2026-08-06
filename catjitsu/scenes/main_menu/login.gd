extends Control


var client_authorised = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HTTP/PlayerData.request_completed.connect(_fetch_player_data)
	$HTTP/Register.request_completed.connect(_user_registered)
	$HTTP/Login.request_completed.connect(_user_logged)
	$HTTP/GetPlayerData.request_completed.connect(_populate_player_data)
	Global.scene_manager.music_player.volume_db = -80
	$Login42Panel.hide()
	$LoginOptions.show()
	$RegisterPanel.hide()
	$LoginPanel.hide()
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
	$LoginPanel.hide()
	$RegisterPanel.hide()
	request_tokens(query_param)


func request_tokens(query_param):
	$HTTP/IdentifyClient.request_completed.connect(_uuid_sent)
	while ($Login42Panel.visible and client_authorised == false):
		$HTTP/IdentifyClient.request("http://localhost:8000/identify-client/" + query_param)
		await get_tree().create_timer(2.0).timeout


func _uuid_sent(_result, response_code, _headers, body):
	print()
	print ("--UUID SENT--")
	print ("Response code: ", response_code)
	if not response_code == 200:
		print("Didn't reveive tokens yet: ", response_code)
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		print("Didn't receive tokens yet")
		return
	client_authorised = true
	print("raw json: ", json)
	print()
	var access_token = json.get("access", "")
	print("access token: ", access_token)
	print()
	var refresh_token = json.get("refresh", "")
	print("refresh token: ", refresh_token)
	Global.api.access_token = access_token
	Global.api.refresh_token = refresh_token
	var player_id = json.get("player-id", "")
	print("player id: ", player_id)
	print()
	_request_player_data(player_id)


func _request_player_data(player_id):
	print("Request player data: ", player_id)
	print("http://localhost:8080/player/", str(player_id).pad_decimals(0))
	$HTTP/PlayerData.request("http://localhost:8000/player/" + str(player_id).pad_decimals(0))

func _fetch_player_data(result, response_code, headers, body):
	print()
	print("--fetch player data--")
	print()
	print("response code: ", response_code)
	if response_code != 200:
		print("Server didn't answer")
		return
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		print ("player json: ", json)
		Global.profile.id = json.get("id", "")
		Global.profile.avatar = json.get("avatar", "")
		Global.profile.name = json.get("username", "")
		Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)
		
		Global.config.language = json.get("preferences").get("language")
		Global.config.volume = json.get("preferences").get("volume")
		print("g c v ", Global.config.volume)
		Global.update_config()
	else:
		print ("player doesnt exist")


func _on_panel_back_button_pressed() -> void:
	$Login42Panel.hide()
	$LoginPanel.hide()
	$RegisterPanel.hide()
	$LoginOptions.show()


func _on_register_pressed() -> void:
	$Login42Panel.hide()
	$LoginPanel.hide()
	$RegisterPanel.show()
	$LoginOptions.hide()


func _on_register_enter_button_pressed() -> void:
	var username = $RegisterPanel/MarginContainer/VBoxContainer/Username.text
	var password = $RegisterPanel/MarginContainer/VBoxContainer/Password.text
	var request_body = "{\"username\": \""+ username + "\", \"password\": \"" + password + "\"}"
	print(request_body)
	var request_headers = ["Content-Type: application/json"]
	$HTTP/Register.request("http://localhost:8000/register/", request_headers, HTTPClient.METHOD_POST, request_body)


func _on_login_button_pressed() -> void:
	var username = $LoginPanel/MarginContainer/VBoxContainer/Username.text
	var password = $LoginPanel/MarginContainer/VBoxContainer/Password.text
	var request_body = "{\"username\": \""+ username + "\", \"password\": \"" + password + "\"}"
	print(request_body)
	var request_headers = ["Content-Type: application/json"]
	$HTTP/Login.request("http://localhost:8000/login/", request_headers, HTTPClient.METHOD_POST, request_body)


func _user_registered(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print("User registered")
	print(response_code)
	print(json)

func _user_logged(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	print("User logged")
	print(response_code)
	print(json)
	
	var token = json.get("token", "")
	var request_headers = ["Content-Type: application/json", "Authorization: Token " + token]
	
	print (request_headers)
	
	$HTTP/GetPlayerData.request("http://localhost:8000/me/", request_headers, HTTPClient.METHOD_GET)
	


func _populate_player_data(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	Global.profile.id = json.get("id", "")
	Global.profile.username = json.get("username", "")
	print(Global.profile.username)
	Global.profile.avatar = json.get("avatar", "")
	
	Global.config.volume = json.get("volume", "")
	Global.config.screenreader = json.get("screenreader", "")
	Global.config.language = json.get("language", "")
	
	
	Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)
	
	print (json)


func _on_login_pressed() -> void:
	$Login42Panel.hide()
	$LoginPanel.show()
	$RegisterPanel.hide()
	$LoginOptions.hide()
