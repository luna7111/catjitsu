extends Node

const PORT = 8080
const MAX_CONNECTIONS = 2

# Shared with Client via NetworkAPI
var players = {}

func _ready():
	print("Starting server. Instance:", get_instance_id())
	# Godot High-Level API signals
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	# NetworkAPI signals
	NetworkAPI.player_registered.connect(_on_player_registered)
	# Start the server
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error != OK:
		print("Could not start server")
		return
	multiplayer.multiplayer_peer = peer
	print("Server running on port:", PORT)

# Registers a player into the Lobby, updates array and emits signal to start
func _on_player_registered(id, info):
	players[id] = info
	NetworkAPI.update_players.rpc(players)
	if players.size() == MAX_CONNECTIONS:
		for peer in players:
			NetworkAPI.begin_game.rpc_id(peer)

# Basic debug
func _on_player_connected(id):
	print("Player connected:", id)

func _on_player_disconnected(id):
	print("Player disconnected:", id)
	players.erase(id)
	NetworkAPI.update_players.rpc(players)
