extends Node

@onready var opponent = $Opponent
@onready var player = $Player
@onready var battle_manager = $BattleLogic/BattleManager

func _ready():
	battle_manager.opponent = opponent
	opponent.controller = opponent.controller_network
	battle_manager.player = player
	NetworkAPI.decks_received.connect(_on_decks_received)
	NetworkAPI.server_disconnected.connect(_on_server_disconnected)
	NetworkAPI.match_aborted.connect(_on_match_aborted)
	battle_manager.game_finished.connect(_on_game_finished)

func _on_decks_received(my_deck, opponent_deck):
	print("Decks received")
	player.setup(my_deck)
	opponent.setup(opponent_deck)

# When backend is implemented, make a NetworkAPI call to result
func _on_game_finished():
	#NetworkAPI.report_match_finished(result)
	#multiplayer.multiplayer_peer.close()
	get_tree().get_multiplayer().multiplayer_peer.close()
	Global.scene_manager.switch_scene(
		"res://scenes/scene_manager.tscn",
		false
	)

func _on_server_disconnected():
	print("MultiplayerMain received disconnect")
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	Global.scene_manager.switch_scene(
		"res://scenes/scene_manager.tscn",
		false
	)

func _on_opponent_disconnected(_id):
	print("Opponent disconnected")
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	Global.scene_manager.switch_scene(
		"res://scenes/scene_manager.tscn",
		false
	)
	
func _on_match_aborted():
	print("Opponent left the match")
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	Global.scene_manager.switch_scene(
		"res://scenes/scene_manager.tscn",
		false
	)
