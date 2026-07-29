extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const SERVER_URL = "ws://localhost:8080"

# Shared with Server via NetworkAPI
var players = {}
var connected = false

var player_info = {
	"name": "Name"
}

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
	# Send player info to NetworkAPI (id = 1)
	NetworkAPI.register_player.rpc_id(1, player_info)

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
		true)
