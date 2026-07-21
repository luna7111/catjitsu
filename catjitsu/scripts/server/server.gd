extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)


const PORT = 8080
const MAX_CONNECTIONS = 2


var players = {}


func _ready():
	print("Starting server. Instance:", get_instance_id())
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	var peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error != OK:
		print("Could not start server")
		return
	multiplayer.multiplayer_peer = peer
	
	print("Server running on port:", PORT)

func _on_player_connected(id):
	print("Player connected:", id)


@rpc("any_peer", "reliable")
func register_player(info):
	var id = multiplayer.get_remote_sender_id()
	print("Registering:", id, info)
	players[id] = info
	player_connected.emit(id, info)
	# Tell everyone about the new player
	update_players.rpc(players)


@rpc("authority", "reliable")
func update_players(current_players):
	players = current_players


func _on_player_disconnected(id):
	print("Player disconnected:", id)
	players.erase(id)
	player_disconnected.emit(id)
	update_players.rpc(players)
