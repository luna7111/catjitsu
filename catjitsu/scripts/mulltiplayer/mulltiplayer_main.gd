extends Node

@onready var opponent = $Opponent
@onready var player = $Player
@onready var battle_manager = $BattleLogic/BattleManager

func _ready():
	battle_manager.opponent = opponent
	opponent.controller = opponent.controller_network
	battle_manager.player = player
	NetworkAPI.decks_received.connect(_on_decks_received)

func _on_decks_received(my_deck, opponent_deck):
	print("Decks received")
	player.setup(my_deck)
	opponent.setup(opponent_deck)
