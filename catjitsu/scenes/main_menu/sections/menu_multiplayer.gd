extends CanvasLayer


@onready var host_button = $MarginContainer/HBoxContainer/Button
@onready var join_button = $MarginContainer/HBoxContainer/VBoxContainer/Button
@onready var play_button = $MarginContainer/HBoxContainer/PlayGameButton

func _ready():
	host_button.pressed.connect(Lobby.create_game)
	join_button.pressed.connect(Lobby.join_game)
	play_button.pressed.connect(Lobby._on_start_game_pressed)
