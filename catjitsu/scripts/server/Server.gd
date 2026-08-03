extends Node

const PORT = 8080
const MAX_CONNECTIONS = 2

# Shared with Client via NetworkAPI
var players = {}
var player_decks = {}
var submitted_cards = {}

# Room logic
var rooms = {}
var player_rooms = {}

const DEFAULT_DECK = [
	"Barbacute",
	"Bigpaw",
	"Brainfreeze",
	"Catzilla",
	"Choco",
	"Furcone",
	"Katcren",
	"Kiro",
	"Match",
	"Papercut beach",
	"Papercut mountains",
	"Papercut volcano",
	"Partyhat",
	"Purrsa",
	"Rubberduck",
	"Snowcat",
	"Towel",
	"Troublemaker"
]

func _ready():
	print("Starting server. Instance:", get_instance_id())
	# Godot High-Level API signals
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	# NetworkAPI signals
	NetworkAPI.player_registered.connect(_on_player_registered)
	NetworkAPI.card_submitted.connect(_on_card_submitted)
	# NetworkAPI Room logic
	NetworkAPI.room_create_requested.connect(_on_room_create_requested)
	NetworkAPI.room_join_requested.connect(_on_room_join_requested)
	
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

func _on_room_create_requested(peer_id, player_info):
	var room_code = generate_room_code()
	rooms[room_code] = {
		"host": peer_id,
		"players": {
			peer_id: player_info
		}
	}
	player_rooms[peer_id] = room_code
	print("Created room:", room_code)
	NetworkAPI.notify_room_created.rpc_id(peer_id, room_code)

func generate_room_code():
	const CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
	var code = ""
	for i in range(6):
		code += CHARS[randi() % CHARS.length()]
	return code

func _on_room_join_requested(peer_id, room_code, player_info):
	if !rooms.has(room_code):
		NetworkAPI.notify_room_join_failed.rpc_id(peer_id, "Room not found")
		return
	var room = rooms[room_code]
	if room.players.size() >= MAX_CONNECTIONS:
		NetworkAPI.notify_room_join_failed.rpc_id(peer_id, "Room is full")
		return
	room.players[peer_id] = player_info
	player_rooms[peer_id] = room_code
	print("Player joined room:", room_code)
	NetworkAPI.notify_room_joined.rpc_id(peer_id)
	NetworkAPI.notify_room_joined.rpc_id(room.host)
	print("Players in room:", room.players.size())
	if room.players.size() == MAX_CONNECTIONS:
		print("Room is full, starting game")
		#prepare_decks(room_code)
		for player in room.players.keys():
			NetworkAPI.begin_game.rpc_id(player)
		# Important! Prepare decks must be called after starting a game
		# If not, it will create a race condition and decks will never arrive
		prepare_decks(room_code)

func prepare_decks(room_code):
	print("Preparing decks")
	var room = rooms[room_code]
	var ids = room.players.keys()
	var deck1 = DEFAULT_DECK.duplicate()
	deck1.shuffle()
	var deck2 = DEFAULT_DECK.duplicate()
	deck2.shuffle()
	if !room.has("decks"):
		room.decks = {}
	room.decks[ids[0]] = deck1
	room.decks[ids[1]] = deck2
	NetworkAPI.receive_decks.rpc_id(
		ids[0],
		room.decks[ids[0]],
		room.decks[ids[1]]
	)
	NetworkAPI.receive_decks.rpc_id(
		ids[1],
		room.decks[ids[1]],
		room.decks[ids[0]]
	)

# Basic debug
func _on_player_connected(id):
	print("Player connected:", id)


func _on_player_disconnected(id):
	print("Player disconnected:", id)
	players.erase(id)
	submitted_cards.erase(id)
	if player_rooms.has(id):
		var room_code = player_rooms[id]
		if rooms.has(room_code):
			var room = rooms[room_code]
			for player_id in room.players.keys():
				if player_id != id and multiplayer.get_peers().has(player_id):
					print("Sending abort to:", player_id)
					NetworkAPI.match_has_aborted.rpc_id(player_id)
					player_rooms.erase(player_id)
			rooms.erase(room_code)
		player_rooms.erase(id)
	NetworkAPI.update_players.rpc(players)

#old
#func _on_player_disconnected(id):
	#print("Player disconnected:", id)
	#players.erase(id)
	#submitted_cards.erase(id)
	#if player_rooms.has(id):
		#var room_code = player_rooms[id]
		#print("Player was in room:", room_code)
		#if rooms.has(room_code):
			#var room = rooms[room_code]
			#for player_id in room.players.keys():
				#if player_id != id and multiplayer.get_peers().has(player_id):
					#print("Sending abort to:", player_id)
					#NetworkAPI.match_has_aborted.rpc_id(player_id)

#old
#func _on_player_disconnected(id):
	#print("Player disconnected:", id)
	#players.erase(id)
	#submitted_cards.erase(id)
	## Check if player belonged to a room
	#if player_rooms.has(id):
		#var room_code = player_rooms[id]
		#if rooms.has(room_code):
			#var room = rooms[room_code]
			## Notify remaining players in this room
			#for player_id in room.players.keys():
				#if player_id != id:
					#print("Notifying player about opponent disconnect:", player_id)
					#NetworkAPI.match_has_aborted.rpc_id(player_id)
			## Remove disconnected player from room
			#room.players.erase(id)
			#print("Players left in room:", room.players.size())
			## Delete empty room
			#if room.players.is_empty():
				#print("Deleting room:", room_code)
				#rooms.erase(room_code)
		#player_rooms.erase(id)
	#NetworkAPI.update_players.rpc(players)

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
