extends Node

const DEFAULT_DECK = [
	"World", "World", "World",
	"Priestess", "Priestess", "Priestess",
	"Fool", "Fool", "Fool"
]
@onready var opponent = $Opponent
@onready var player = $Player
@onready var battle_manager = $BattleLogic/BattleManager

func _ready():
	battle_manager.opponent = opponent
	opponent.controller = opponent.controller_ai
	battle_manager.player = player
	battle_manager.game_finished.connect(_on_game_finished)
	
	# Setup player deck
	var player_deck = DEFAULT_DECK.duplicate()
	player_deck.shuffle()
	player.setup(player_deck)
	
	# Setup opponent deck
	var opponent_deck = DEFAULT_DECK.duplicate()
	opponent_deck.shuffle()
	opponent.setup(opponent_deck)

func _on_game_finished():
	Global.scene_manager.switch_scene(
		"res://scenes/scene_manager.tscn",
		false
	)
