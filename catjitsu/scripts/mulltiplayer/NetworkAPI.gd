extends Node

# Network API for send and receive network messages from client to server
# I.e, register player, play_card, end turn, begin_game

# Signals
signal player_registered(peer_id, info)
signal players_updated(players)
signal decks_received(player_deck, opponent_deck)
signal card_submitted(peer_id, card_id)
signal opponent_card_received(card_id)
signal game_started

func _ready():
	print("NetworkAPI path: ", get_path())

#
# Client -> Server
#

# Currently working on this
@rpc("any_peer", "reliable")
func register_player(info):
	var id = multiplayer.get_remote_sender_id()
	player_registered.emit(id, info)

@rpc("any_peer", "reliable")
func submit_card(card_id):
	var peer_id = multiplayer.get_remote_sender_id()
	card_submitted.emit(peer_id, card_id)

#
# Server -> Client
#
@rpc("authority", "reliable")
func update_players(current_players):
	players_updated.emit(current_players)

@rpc("authority", "reliable")
func begin_game():
	print("Game started!")
	game_started.emit()

@rpc("authority", "reliable")
func receive_opponent_card(card_id):
	opponent_card_received.emit(card_id)

@rpc("authority", "reliable")
func receive_decks(player_deck, opponent_deck):
	print("Received decks")
	decks_received.emit(player_deck, opponent_deck)
