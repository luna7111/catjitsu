extends Node

const PORT = 8080
const MAX_CONNECTIONS = 2

# Shared with Client via NetworkAPI
var players = {}
var player_decks = {}
var submitted_cards = {}

const DEFAULT_DECK = [
	"World", "World", "World",
	"Priestess", "Priestess", "Priestess",
	"Fool", "Fool", "Fool"
]

func _ready():
	print("Starting server. Instance:", get_instance_id())
	# Godot High-Level API signals
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	# NetworkAPI signals
	NetworkAPI.player_registered.connect(_on_player_registered)
	NetworkAPI.card_submitted.connect(_on_card_submitted)
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
		prepare_decks()

func prepare_decks():
	print("Preparing decks")
	var ids = players.keys()
	var deck1 = DEFAULT_DECK.duplicate()
	deck1.shuffle()
	var deck2 = DEFAULT_DECK.duplicate()
	deck2.shuffle()
	player_decks[ids[0]] = deck1
	player_decks[ids[1]] = deck2
	
	# Send deck data to player 1
	NetworkAPI.receive_decks.rpc_id(
		ids[0],
		player_decks[ids[0]],
		player_decks[ids[1]]
	)
	
	# Send deck data to player 2
	NetworkAPI.receive_decks.rpc_id(
		ids[1],
		player_decks[ids[1]],
		player_decks[ids[0]]
)

# Basic debug
func _on_player_connected(id):
	print("Player connected:", id)

func _on_player_disconnected(id):
	print("Player disconnected:", id)
	players.erase(id)
	submitted_cards.erase(id)
	NetworkAPI.update_players.rpc(players)

# Receives player_card
func _on_card_submitted(peer_id, card_name):
	submitted_cards[peer_id] = card_name
	if submitted_cards.size() == MAX_CONNECTIONS:
		var ids = submitted_cards.keys()
		var player1 = ids[0]
		var player2 = ids[1]
		var card1 = submitted_cards[player1]
		var card2 = submitted_cards[player2]
		NetworkAPI.receive_opponent_card.rpc_id(player1, card2)
		NetworkAPI.receive_opponent_card.rpc_id(player2, card1)
		submitted_cards.clear()
