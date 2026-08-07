extends Control


var client_authorised = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	Global.config = Global.default_config
	
	Global.scene_manager.api_up.connect(_show_login_buttons)
	Global.scene_manager.api_down.connect(_hide_login_buttons)
	
	if (Global.api_working == true):
		_show_login_buttons()
	else:
		_hide_login_buttons()
	
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
	Global.logged_in = false
	
	Global.profile = Global.default_profile
	
	Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)


func _on_login_intra_pressed() -> void:
	var exchange_uuid = UUID.v4()
	var query_param = "?exchange_uuid=" + exchange_uuid
	print(exchange_uuid)
	OS.shell_open(Global.api_host + "/auth/42/login/" + query_param)
	$LoginOptions.hide()
	$Login42Panel.show()
	$LoginPanel.hide()
	$RegisterPanel.hide()
	request_tokens(query_param)


func request_tokens(query_param):
	$HTTP/IdentifyClient.request_completed.connect(_uuid_sent)
	while ($Login42Panel.visible and client_authorised == false):
		$HTTP/IdentifyClient.request(Global.api_host + "/identify-client/" + query_param)
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
	
	Global.token = json.get("token", "")
	var player_id = json.get("player-id", "")
	print("player id: ", player_id)
	print()
	_request_player_data(player_id)


func _request_player_data(player_id):

	var token = Global.token
	var request_headers = ["Content-Type: application/json", "Authorization: Token " + token]
	
	$HTTP/GetPlayerData.request(Global.api_host + "/me/", request_headers, HTTPClient.METHOD_GET)

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
		
		Global.config.language = json.get("preferences").get("language")
		Global.config.volume = json.get("preferences").get("volume")
		print("g c v ", Global.config.volume)
		Global.update_config()
		
		Global.logged_in = true
		print("LOGED IN? : ", Global.logged_in)
		Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)
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
	$HTTP/Register.request(Global.api_host + "/register/", request_headers, HTTPClient.METHOD_POST, request_body)


func _on_login_button_pressed() -> void:
	var username = $LoginPanel/MarginContainer/VBoxContainer/Username.text
	var password = $LoginPanel/MarginContainer/VBoxContainer/Password.text
	var request_body = "{\"username\": \""+ username + "\", \"password\": \"" + password + "\"}"
	print(request_body)
	var request_headers = ["Content-Type: application/json"]
	print("API HOST ", Global.api_host)
	$HTTP/Login.request(Global.api_host + "/login/", request_headers, HTTPClient.METHOD_POST, request_body)


func _user_registered(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	$RegisterPanel/MarginContainer/VBoxContainer/UsernameReason.text = ""
	$RegisterPanel/MarginContainer/VBoxContainer/PasswordReason.text = ""
	
	if (response_code == 201 or response_code == 200):
		print("User registered")
		print(response_code)
		print(json)
		
		var username = $RegisterPanel/MarginContainer/VBoxContainer/Username.text
		var password = $RegisterPanel/MarginContainer/VBoxContainer/Password.text
		var request_body = "{\"username\": \""+ username + "\", \"password\": \"" + password + "\"}"
		print(request_body)
		var request_headers = ["Content-Type: application/json"]
		$HTTP/Login.request(Global.api_host + "/login/", request_headers, HTTPClient.METHOD_POST, request_body)
	else:
		var username_reason = json.get("username", "")
		var password_reason = json.get("password", "")
		if username_reason is Array and username_reason.size() > 0:
			$RegisterPanel/MarginContainer/VBoxContainer/UsernameReason.text = username_reason[0]
		if password_reason is Array and password_reason.size() > 0:
			$RegisterPanel/MarginContainer/VBoxContainer/PasswordReason.text = password_reason[0]


func _user_logged(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	$LoginPanel/MarginContainer/VBoxContainer/LoginReason.text = ""
	
	if response_code == 200:
		print ("LOGIN RES CODE ", response_code)
		print("User logged")
		print(response_code)
		print(json)
		
		var token = json.get("token", "")
		Global.token = token
		var request_headers = ["Content-Type: application/json", "Authorization: Token " + token]
		
		print (request_headers)
		
		$HTTP/GetPlayerData.request(Global.api_host + "/me/", request_headers, HTTPClient.METHOD_GET)
	else:
		$LoginPanel/MarginContainer/VBoxContainer/LoginReason.text = "Invalid username or password"


func _populate_player_data(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	Global.profile.id = json.get("id", "")
	Global.profile.username = json.get("username", "")
	print(Global.profile.username)
	Global.profile.avatar = json.get("avatar", "")
	
	Global.config.volume = int(json.get("volume", ""))
	Global.config.screenreader = json.get("screenreader", "")
	Global.config.language = json.get("language", "")
	
	Global.logged_in = true
	print("LOGGED IN")
	Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)
	
	print (json)


func _on_login_pressed() -> void:
	$Login42Panel.hide()
	$LoginPanel.show()
	$RegisterPanel.hide()
	$LoginOptions.hide()


func _show_login_buttons():
	$LoginOptions/VBoxContainer/HBoxContainer.show()
	$LoginOptions/VBoxContainer/LoginIntra.show()
	$LoginOptions/VBoxContainer/ServerMsg.hide()

func _hide_login_buttons():
	$LoginOptions/VBoxContainer/HBoxContainer.hide()
	$LoginOptions/VBoxContainer/LoginIntra.hide()
	$LoginOptions/VBoxContainer/ServerMsg.show()


func _on_login_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($LoginOptions/VBoxContainer/HBoxContainer/Login.text), Global.tts_voice)


func _on_register_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($LoginOptions/VBoxContainer/HBoxContainer/Register.text), Global.tts_voice)


func _on_login_intra_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($LoginOptions/VBoxContainer/LoginIntra.text), Global.tts_voice)


func _on_skip_login_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($LoginOptions/VBoxContainer/SkipLogin.text), Global.tts_voice)


func _on_back_button_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($Login42Panel/MarginContainer/VBoxContainer/BackButton.text), Global.tts_voice)


func _on_login_42_panel_visibility_changed() -> void:
	if $Login42Panel.visible and DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($Login42Panel/MarginContainer/VBoxContainer/WaitingIntra.text), Global.tts_voice)
		DisplayServer.tts_speak(TranslationServer.tr($Login42Panel/MarginContainer/VBoxContainer/CheckBrowser.text), Global.tts_voice)


func _on_tos_pressed() -> void:
	OS.shell_open("https://" + Global.hostname + ":" + Global.game_port + "/TOS.html")


func _on_pp_pressed() -> void:
	OS.shell_open("https://" + Global.hostname + ":" + Global.game_port + "/PP.html")


func _on_language_item_selected(index: int) -> void:
	match index:
		0:
			Global.config.language = "English"
		1:
			Global.config.language = "Spanish"
		2:
			Global.config.language = "French"
	Global.update_translations()
