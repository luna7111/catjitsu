extends Node

@onready var opponent = $Opponent
@onready var player = $Player
@onready var battle_manager = $BattleLogic/BattleManager

func _ready():
	battle_manager.opponent = opponent
	opponent.controller = opponent.controller_network
	battle_manager.player = player
	NetworkAPI.decks_received.connect(_on_decks_received)
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
