extends Node

signal settings_changed

var scene_manager : SceneManager

enum InputMode {MOUSE, KEYBOARD, CONTOLLER}
var current_input_mode = InputMode.MOUSE

var tts_voice
var tts_avaiable: bool = false

# URL access, as it is setted from NGINX
var host
var hostname
var api_host
var api_port = "8000"
var game_port = "8443"
var websocket_url
var api_base

var api_working = false
var logged_in = false

var token = ""

var avatar_list = [
		"Apolito",
		"Apoloto",
		"Rudy",
		"Rodolfo",
		"Kimi",
		"Riku"
]

var default_profile = {
	id = -1,
	username = "Guest",
	avatar = "Apolito"
}


var default_config = {
	volume = 50,
	language = "English",
	screenreader = true
}

var profile = {
	id = -1,
	username = "Guest",
	avatar = "Apolito"
}


var config = {
	volume = 50,
	language = "English",
	screenreader = true
}


var api = {
	access_token = "",
	refresh_token = ""
}

var music_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	configure_network()
	get_user_config()
	get_user_profile()
	update_config()
	update_voices()

func update_voices():
	var tts_all_voices = DisplayServer.tts_get_voices_for_language(TranslationServer.get_locale())
	if not tts_all_voices.is_empty():
		tts_voice = tts_all_voices[0]
		tts_avaiable = true
	else:
		tts_avaiable = false
		print("VOICES BAD :(")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func get_user_config():
	pass


func get_user_profile():
	pass


func update_config():
	update_translations()
	settings_changed.emit()


func update_translations():
	match config.language:
		"English":
			TranslationServer.set_locale("en")
			print("Locale set to \"en\"")
		"Spanish":
			TranslationServer.set_locale("es")
		"French":
			TranslationServer.set_locale("fr")

# ALEX: retrieve IP address from the brosers perspective as served / configured in NGINX
func configure_network() -> void:
	if OS.has_feature("web"):
		var protocol = JavaScriptBridge.eval("window.location.protocol")
		host = JavaScriptBridge.eval("window.location.host")
		hostname = JavaScriptBridge.eval("window.location.hostname")
		#api_host = protocol + "//" + hostname + ":" + api_port
		api_host = protocol + "//" + hostname + ":" + game_port + "/api"

		var ws_protocol := "ws"
		if protocol == "https:":
			ws_protocol = "wss"

		websocket_url = "%s://%s/ws" % [ws_protocol, host]
		api_base = "%s//%s/api" % [protocol, host]

		print("--------------------------------")
		print("Host:", host)
		print("WebSocket:", websocket_url)
		print("API:", api_base)
		print("--------------------------------")

	else:
		host = "localhost:9000"
		hostname = "localhost"
		api_host = "http://localhost:" + api_port
		websocket_url = "ws://localhost:9000"
		api_base = "http://localhost:9000/api"
