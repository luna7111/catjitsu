extends Node2D

var peer = WebSocketMultiplayerPeer.new()
const SERVER_URL = "ws://localhost:8080"
const PORT = 8080

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
	multiplayer.peer_connected.connect(_on_peer_connected)
	
	# Instansiate player hand, wip
	#var player_scene = player_field_scene.instantiate()
	#add_child(player_scene)

func connect_client():
	print ("connect client")
	# This needs more guarding
	peer.create_client(SERVER_URL)
	multiplayer.multiplayer_peer = peer
	
	# Instansiate player hand, wip
	#var player_scene = player_field_scene.instantiate()
	#add_child(player_scene)

func _on_peer_connected(id):
	print("Client connected")
	print(id)
