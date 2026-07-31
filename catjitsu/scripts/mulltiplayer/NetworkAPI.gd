extends Node

# Network API for send and receive network messages from client to server
# I.e, register player, play_card, end turn, begin_game

#
# Signals
#

# Signals for lobby
signal player_registered(peer_id, info)
signal players_updated(players)
signal game_started

# Signals for room
signal room_create_requested(peer_id, player_info)
signal room_join_requested(peer_id, room_code, player_info)
signal room_created(room_code)
signal room_joined()
signal room_join_failed(reason)

# Signals for game logic
signal decks_received(player_deck, opponent_deck)
signal card_submitted(peer_id, card_id)
signal opponent_card_received(card_id)


func _ready():
	print("NetworkAPI path: ", get_path())

#
# Client -> Server
#

# Lobby logic, should be obsolote after room logic
@rpc("any_peer", "reliable")
func register_player(info):
	var id = multiplayer.get_remote_sender_id()
	player_registered.emit(id, info)

@rpc("any_peer", "reliable")
func submit_card(card_id):
	var peer_id = multiplayer.get_remote_sender_id()
	card_submitted.emit(peer_id, card_id)

# Multiple rooms logic
@rpc("any_peer", "reliable")
func create_room(player_info):
	var peer_id = multiplayer.get_remote_sender_id()
	room_create_requested.emit(peer_id, player_info)

@rpc ("any_peer", "reliable")
func join_room(room_code, player_info):
	var peer_id = multiplayer.get_remote_sender_id()
	room_join_requested.emit(peer_id, room_code, player_info)

#
# Server -> Client
#

# Lobby logic
@rpc("authority", "reliable")
func update_players(current_players):
	players_updated.emit(current_players)

@rpc("authority", "reliable")
func begin_game():
	print("Game started!")
	game_started.emit()

# Room logic
@rpc ("authority", "reliable")
func notify_room_created(room_code):
	room_created.emit(room_code)

@rpc("authority", "reliable")
func notify_room_joined():
	room_joined.emit()

@rpc("authority", "reliable")
func notify_room_join_failed(reason):
	room_join_failed.emit(reason)

# Game logic
@rpc("authority", "reliable")
func receive_opponent_card(card_id):
	opponent_card_received.emit(card_id)

@rpc("authority", "reliable")
func receive_decks(player_deck, opponent_deck):
	print("Received decks")
	decks_received.emit(player_deck, opponent_deck)
