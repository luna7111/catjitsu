extends Node

#signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const SERVER_URL = "ws://localhost:8080"

# Shared with Server via NetworkAPI
var players = {}
var connected = false

var player_info = {
	"name": "Name"
}

# Room logic
enum LobbyAction {
	NONE,
	HOST,
	JOIN
}

var pending_action = LobbyAction.NONE
var pending_room_code = ""

func _ready():
	print("Starting multiplayer. Instance:", get_instance_id())
	# Internal signals from Multiplayer to Lobby
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	# Signals from Lobby to NetworkAPI
	NetworkAPI.players_updated.connect(_on_players_updated)
	NetworkAPI.game_started.connect(_on_game_started)
	# Signals for room logic 
	NetworkAPI.room_created.connect(_on_room_created)
	NetworkAPI.room_joined.connect(_on_room_joined)
	NetworkAPI.room_join_failed.connect(_on_room_join_failed)

# Joins a game in the stablished webserv / port
func join_game():
	# Basic check
	if connected:
		return
	
	# Creates a WebSocketMultiplayerPeer and connects to URL as client
	print("Connecting to server")
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_client(SERVER_URL)
	
	# If everything ok, we change peer and confirm the conexion
	if error != OK:
		print("Connection error:", error)
		return
	multiplayer.multiplayer_peer = peer


# Recive network connected_to_server

func _on_connected_ok():
	connected = true
	print("Connected. My ID:", multiplayer.get_unique_id())

	match pending_action:
		LobbyAction.HOST:
			NetworkAPI.create_room.rpc_id(1, player_info)

		LobbyAction.JOIN:
			NetworkAPI.join_room.rpc_id(
				1,
				pending_room_code,
				player_info
			)

# Old version
#func _on_connected_ok():
	#connected = true
	#print("Connected. My ID:", multiplayer.get_unique_id())
	## Send player info to NetworkAPI (id = 1)
	## Lets remove this by the moment!
	##NetworkAPI.register_player.rpc_id(1, player_info)

# Notifies that a player has connected to the server
func _on_peer_connected(id):
	print("Peer connected:", id)

# Notifies that a player has disconnected from the server
func _on_peer_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)

# Failed to connect to the server
func _on_connected_fail():
	print("Connection failed")
	print("Peer status:", multiplayer.multiplayer_peer.get_connection_status())
	connected = false

# The server has disconnected
func _on_server_disconnected():
	print("Server disconnected")
	connected = false
	players.clear()
	server_disconnected.emit()

func _on_players_updated(new_players):
	players = new_players

func _on_game_started():
	print("Starting the game")
	Global.scene_manager.switch_scene(
		"res://scenes/multiplayer/multiplayer_main.tscn",
		false)

# Room logic 
func create_room():
	if !connected:
		return
	NetworkAPI.create_room.rpc_id(1, player_info)

#func join_room(room_code):
	#if !connected:
		#return
	#NetworkAPI.join_room.rpc_id(
		#1,
		#room_code,
		#player_info
	#)
	#
func join_room(room_code):
	pending_action = LobbyAction.JOIN
	pending_room_code = room_code
	join_game()

func host_game():
	pending_action = LobbyAction.HOST
	join_game()

func _on_room_created(room_code):
	print("Room created:", room_code)

func _on_room_joined():
	print("Joined room!")
	
func _on_room_join_failed(reason):
	print("Join failed:", reason)
