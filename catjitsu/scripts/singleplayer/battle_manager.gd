extends Node

# Opponent Data
@onready var opponent = $"../../Opponent"
var opponent_card_on_slot

# Player Data
@onready var player = $"../../Player"
var player_card_on_slot

# Aftermath
signal game_finished

# Battle Logic
var battle_timer
var player_points = {
		"Fire" = 0,
		"Ice" = 0,
		"Water" = 0,
		"None" = 0
	}
var opponent_points = {
		"Fire" = 0,
		"Ice" = 0,
		"Water" = 0,
		"None" = 0
	}
enum BATTLE_RESULT {
	PLAYER,
	OPPONENT,
	TIE,
}

@onready var battle_animation_manager = $"../BattleAnimationManager"

func _ready() -> void:
	battle_timer = $"../BattleTimer"
	battle_timer.one_shot = true
	battle_timer.wait_time = 1.0
	player.card_played.connect(_on_player_card_played)

func _on_player_card_played(card):
	player_card_on_slot = card
	# Send to multiplayer NetworkAPI, it does nothing on singleplayer
	# BUG: Right now, after doing a multiplayer match, it stays connected to peer and calls in singleplayer
	if multiplayer.has_multiplayer_peer() and !multiplayer.is_server():
		NetworkAPI.submit_card.rpc_id(1, card.id)
	await play_turn()

# Logic and animations for opponent turn. 
# Picks card with hightest attack and play its
# Then calculates battle result
func play_turn():
	# Initial holdup for dramatic effect
	battle_timer.start()
	await battle_timer.timeout

	# Selects card either from OpponentAI or OpponentNetwork thorugh opponent.choose_card API
	opponent_card_on_slot = await opponent.choose_card()
	battle_animation_manager.play_card_animation(opponent_card_on_slot, opponent.slot)
	await opponent.play_card(opponent_card_on_slot)
	
	# Calculate card points
	await battle_phase()
	# Adds points to players and ends turn / game
	end_turn()

func battle_phase():
	# Funny crash animation
	await battle_animation_manager.animate_cards_battle_phase(
		player_card_on_slot, 
		opponent_card_on_slot)
	
	# Determine who won this round and update data
	var battle_result = calculate_battle_result()
	await update_battle_result(battle_result)
	
	# Destroy all cards played
	destroy_card(opponent_card_on_slot)
	destroy_card(player_card_on_slot)

# Card comparison logic
func calculate_battle_result():
	var result = [BATTLE_RESULT.TIE, "None"]
	if opponent_card_on_slot.type == player_card_on_slot.type:
		if opponent_card_on_slot.points == player_card_on_slot.points:
			result = [BATTLE_RESULT.TIE, "None"]
		else:
			var winner = opponent_card_on_slot.points > player_card_on_slot.points
			if winner == true:
				result[0] = BATTLE_RESULT.OPPONENT
			else:
				result[0] = BATTLE_RESULT.PLAYER
			result[1] = opponent_card_on_slot.type
	elif (opponent_card_on_slot.type == "Fire" && player_card_on_slot.type == "Ice" 
		or opponent_card_on_slot.type == "Ice" && player_card_on_slot.type == "Water"
		or opponent_card_on_slot.type == "Water" && player_card_on_slot.type == "Fire") :
			result = [BATTLE_RESULT.OPPONENT, opponent_card_on_slot.type]
	else:
		result = [BATTLE_RESULT.PLAYER, player_card_on_slot.type]
	print("Result is: ", result)
	return result

# Update points and visuals
func update_battle_result(battle_result):
	match battle_result[0]:
		BATTLE_RESULT.OPPONENT:
			opponent_points[battle_result[1]] += 1
			battle_animation_manager.show_point(
				battle_result[1], 
				opponent_points[battle_result[1]], 
				"Opponent")
			await battle_animation_manager.opponent_win_animation(player_card_on_slot, opponent_card_on_slot)
		BATTLE_RESULT.PLAYER:
			player_points[battle_result[1]] += 1
			battle_animation_manager.show_point(
				battle_result[1],
				player_points[battle_result[1]], 
				"Player")
			await battle_animation_manager.player_win_animation(player_card_on_slot, opponent_card_on_slot)
		BATTLE_RESULT.TIE:
			await battle_animation_manager.tie_animation(player_card_on_slot, opponent_card_on_slot)

# Logic for ending turn
func end_turn():
	var player_elements = 0
	var opponent_elements = 0
	for key in player_points:
		if player_points[key]:
			player_elements += 1
		if opponent_points[key]:
			opponent_elements +=1
		if (player_points[key] == 3 or player_elements == 3
		or opponent_points[key] == 3 or opponent_elements == 3) :
			print("Game Over!")
			game_finished.emit()
			return
			#get_tree().quit()
		elif !player.has_cards_on_hand():
			print("Player has not cards!")
			game_finished.emit()
			return
			#get_tree().quit()
	
	# Reset turn
	opponent_card_on_slot = null
	player_card_on_slot = null
	player.end_turn()
	opponent.end_turn()

# Cleanup
func destroy_card(selected_card):
	selected_card.queue_free()
