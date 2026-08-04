extends Node

# Autoload Lobby.gd

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

# New
const SERVER_URL = "ws://localhost:8080"
#const SERVER_URL = "wss://localhost:8060/tmp_js_export.html"
const MAX_CONNECTIONS = 2
const PORT = 8080

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

var players_loaded = 0


# Connects all multiplayer signals to our functions
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Call this function from a button signal to join a game
func join_game():
	print("Join game")
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_client(SERVER_URL)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

# Call this function from a button signal to create a server
# In the future, this  will create a dedicate room i'm our backend server
func create_game():
	print("Create game")
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	# Once we have created or server, we ourselves are a player
	# So we send our data through our custom signal with id 1 (host)
	players[1] = player_info
	player_connected.emit(1, player_info)


# Safely removes multiplayer and removes player
func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()

func _on_start_game_pressed():
	if multiplayer.is_server():
		load_game.rpc("res://scenes/mulltiplayer/mulltiplayer_main.tscn")

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			print("All players loaded!")
			#$/root/Game.start_game()
			players_loaded = 0


# Called when a player is connected, acknowledged by multiplayer.peer_connected.connect(_on_player_connected)
# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	# The function only takes player_info argument
	# but the method rpc_id(id) also takes it's id, so it's first in the argument list
	_register_player.rpc_id(id, player_info)
	print("On Host, Player connected: ")
	print(id, player_info)


# Takes the player id via the multiplayer API and adds it to the array of players
@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	
	print("Register player:", new_player_id)
	print(new_player_info)
	
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	print(players)

# Removes player from array and emits custom signal
func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

# Adds player to array and emits custom signal
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	print("Connected to server")
	print("My ID:", multiplayer.get_unique_id())

# If a client disconnects, we just need to remove the multiplayer object
func _on_connected_fail():
	remove_multiplayer_peer()

# # If the server disconnects, we need to remove the multiplayer object and clear the players array
func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()
	print("Server disconnected")
