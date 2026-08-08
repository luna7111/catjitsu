extends Node

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

@onready var opponent = $Opponent
@onready var player = $Player
@onready var battle_manager = $BattleLogic/BattleManager
@onready var result_label = $Player/Result

func _ready():
	var lowpass_effect: AudioEffect = AudioServer.get_bus_effect(1, 0)
	lowpass_effect.set("cutoff_hz", 10000)

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

func _on_game_finished(result):
	match result:
		"Player":
			result_label.text = "You win!"
		"Opponent":
			result_label.text = "You lose!"
		"Tie":
			result_label.text = "It's a tie!"
	result_label.show()
	await get_tree().create_timer(2.0).timeout
	Global.scene_manager.switch_scene(
		"res://scenes/main_menu/menu_home.tscn",
		false
	)
