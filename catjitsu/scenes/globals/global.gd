extends Node

var scene_manager : SceneManager

var profile = {
	name = "Guest123",
	avatar = "Rodolfo"
}


var config = {
	volume = 100,
	language = "English"
}


var api = {
	access_token = "",
	refresh_token = ""
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_user_config()
	get_user_profile()
	update_config()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func get_user_config():
	pass


func get_user_profile():
	pass


func update_config():
	update_translations()


func update_translations():
	match config.language:
		"English":
			TranslationServer.set_locale("en")
			print("Locale set to \"en\"")
		"Spanish":
			TranslationServer.set_locale("es")
		"French":
			TranslationServer.set_locale("fr")
