extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const SERVER_URL = "ws://localhost:8080"

var players = {}
var connected = false

var player_info = {
	"name": "Name"
}


func _ready():
	print("Starting multiplayer. Instance:", get_instance_id())
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)


func join_game():
	if connected:
		return
	print("Connecting to server")
	
	connected = true

	var peer = WebSocketMultiplayerPeer.new()

	var error = peer.create_client(SERVER_URL)

	if error != OK:
		print("Connection error:", error)
		return

	multiplayer.multiplayer_peer = peer


func _on_connected_ok():
	var id = multiplayer.get_unique_id()

	players[id] = player_info

	print("Connected. My ID:", id)

	# Send my info to server
	register_player.rpc_id(1, player_info)


@rpc("any_peer", "reliable")
func register_player(info):
	var id = multiplayer.get_remote_sender_id()

	players[id] = info

	player_connected.emit(id, info)


func _on_player_connected(id):
	print("Peer connected:", id)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_fail():
	print("Connection failed")
	print("Peer status:", multiplayer.multiplayer_peer.get_connection_status())


func _on_server_disconnected():
	print("Server disconnected")
	players.clear()
	server_disconnected.emit()
