extends Node

# Network API for send and receive network messages from client to server
# I.e, register player, play_card, end turn, begin_game

# Signals
signal player_registered(peer_id, info)
signal players_updated(players)
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
