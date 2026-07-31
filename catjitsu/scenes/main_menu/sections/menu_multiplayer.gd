extends CanvasLayer

@onready var host_button = $MarginContainer/HBoxContainer/Button
@onready var join_button = $MarginContainer/HBoxContainer/VBoxContainer/Button
@onready var play_button = $MarginContainer/HBoxContainer/PlayGameButton
@onready var room_code_input = $MarginContainer/HBoxContainer/VBoxContainer/LineEdit
@onready var lobby = $Lobby

# Lobby version
#func _ready():
	#host_button.pressed.connect(Lobby.create_game)
	#join_button.pressed.connect(Lobby.join_game)
	#play_button.disabled = true
	#play_button.pressed.connect(Lobby._on_start_game_pressed)
	#Lobby.player_connected.connect(_on_player_connected)
	#
#func _on_player_connected(id, info):
	#if multiplayer.is_server():
		#if Lobby.players.size() == Lobby.MAX_CONNECTIONS:
			#play_button.disabled = false

# working Lobby pre rooms version
#func _ready():
	#host_button.pressed.connect(LobbyWithServer.create_game)
	#join_button.pressed.connect(Lobby.join_game)
	#play_button.disabled = true
	#play_button.pressed.connect(LobbyWithServer._on_start_game_pressed)
	#LobbyWithServer.player_connected.connect(_on_player_connected)

#func _on_player_connected(id, info):
	#if multiplayer.is_server():
		#if LobbyWithServer.players.size() == Lobby.MAX_CONNECTIONS:
			#play_button.disabled = false

# Rooms version
func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	play_button.disabled = true

func _on_host_pressed():
	lobby.host_game()

func _on_join_pressed():
	var room_code = room_code_input.text.strip_edges().to_upper()
	if room_code == "":
		return
	lobby.join_room(room_code)
