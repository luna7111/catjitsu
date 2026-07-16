extends Node

func _ready():
	var battle_manager = $BattleLogic/BattleManager
	battle_manager.opponent_controller = $Opponent/OpponentAI
