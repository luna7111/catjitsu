extends Node

const DEFAULT_DECK = [
	"World", "World", "World",
	#"Priestess", "Priestess", "Priestess",
	#"Fool", "Fool", "Fool"
]
@onready var opponent = $Opponent
@onready var player = $Player
@onready var battle_manager = $BattleLogic/BattleManager

func _ready():
	battle_manager.opponent = opponent
	opponent.controller = opponent.controller_ai
	battle_manager.player = player
	
	# Setup player deck
	var player_deck = DEFAULT_DECK.duplicate()
	player_deck.shuffle()
	player.setup(player_deck)
	
	# Setup opponent deck
	var opponent_deck = DEFAULT_DECK.duplicate()
	opponent_deck.shuffle()
	opponent.setup(opponent_deck)
