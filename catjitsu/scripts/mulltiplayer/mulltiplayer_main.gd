extends Node2D

# Websocket setup and info
var peer = WebSocketMultiplayerPeer.new()
const SERVER_URL = "ws://localhost:8080"
const MAX_CONNECTIONS = 2
const PORT = 8080

# Player info
var players = {}
var player_info = {"name": "Name"}
var players_loaded = 0

# Server status signals
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

@export var player_field_scene : PackedScene

@onready var host_button_reference = $"../MarginContainer/HBoxContainer/Button"
@onready var client_button_reference = $"../MarginContainer/HBoxContainer/VBoxContainer/Button"

func _ready():
	host_button_reference.pressed.connect(connect_host)
	client_button_reference.pressed.connect(connect_client)

func connect_host():
	print("connect host")
	# This needs more guarding
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_player_connected)
	
	# Instansiate player hand, wip
	#var player_scene = player_field_scene.instantiate()
	#add_child(player_scene)

func connect_client():
	print ("connect client")
	# This needs more guarding
	var error = peer.create_client(SERVER_URL)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	# Instansiate player hand, wip
	#var player_scene = player_field_scene.instantiate()
	#add_child(player_scene)

func _on_player_connected(id):
	print("Client connected")
	print(id)
