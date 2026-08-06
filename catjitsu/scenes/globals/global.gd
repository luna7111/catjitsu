extends Node

signal settings_changed

var scene_manager : SceneManager

enum InputMode {MOUSE, KEYBOARD, CONTOLLER}
var current_input_mode = InputMode.MOUSE

var tts_voice
var tts_avaiable: bool = false

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
	language = "English"
}

var profile = {
	id = -1,
	username = "Guest",
	avatar = "Apolito"
}


var config = {
	volume = 50,
	language = "English"
}


var api = {
	access_token = "",
	refresh_token = ""
}

var music_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	get_user_config()
	get_user_profile()
	update_config()
	var tts_all_voices = DisplayServer.tts_get_voices_for_language(TranslationServer.get_locale())
	if not tts_all_voices.is_empty():
		tts_voice = tts_all_voices[0]
		tts_avaiable = true


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
