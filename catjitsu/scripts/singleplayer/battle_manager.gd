extends Node

# Opponent Data
var opponent
var opponent_card_on_slot

# Player Data
var player
var player_card_on_slot

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

func _on_end_turn_button_pressed() -> void:
	await play_turn()

# Logic and animatios for opponent turn. 
# Picks card with hightest attack and play its
# Then calculates battle result
func play_turn():
	# Activate to implement EndTurnButton
	#$"../EndTurnButton".disabled = true
	#$"../EndTurnButton".visible = false

	# Initial holdup for dramatic effect
	battle_timer.start()
	await battle_timer.timeout

	# Selects opponent card, either from OpponentAI or OpponentNetwork
	opponent_card_on_slot = await opponent.choose_card()
	await play_card(opponent_card_on_slot, opponent)
	# Calculate card points
	await battle_phase()
	# Adds points to players and ends turn / game
	end_turn()

#func play_card(card, participant):
	#match participant:
		#case opponent:
			#

func play_card(card, participant):
	battle_animation_manager.play_card_animation(
		card, 
		participant.slot)
	participant.hand.remove_card_from_hand(opponent_card_on_slot)
	battle_timer.start()
	await battle_timer.timeout

func battle_phase():
	# Funny crash animation
	await battle_animation_manager.animate_cards_battle_phase(
		player_card_on_slot, 
		opponent_card_on_slot)
	
	# Determine who won this round and update data
	var battle_result
	battle_result = calculate_battle_result()
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
			result[0] = opponent_card_on_slot.points > player_card_on_slot.points
			result[1] = opponent_card_on_slot.type
	elif (opponent_card_on_slot.type == "Fire" && player_card_on_slot.type == "Ice" 
		or opponent_card_on_slot.type == "Ice" && player_card_on_slot.type == "Water"
		or opponent_card_on_slot.type == "Water" && player_card_on_slot.type == "Fire") :
			result = [BATTLE_RESULT.OPPONENT, opponent_card_on_slot.type]
	else:
		result = [BATTLE_RESULT.PLAYER, player_card_on_slot.type]
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
			get_tree().quit()
		elif !player.hand.has_cards():
			print("!")
			get_tree().quit()

	#$"../EndTurnButton".disabled = false
	#$"../EndTurnButton".visible = true
	player.deck.reset_draw()
	$"../../CardManager".reset_played_monster()
	opponent_card_on_slot = null
	player_card_on_slot = null
	opponent.slot.card_in_slot = false
	player.slot.card_in_slot = false
	if opponent.deck.has_cards() and player.deck.has_cards():
		opponent.deck.draw_card()
		player.deck.draw_card()

# Cleanup
func destroy_card(selected_card):
	selected_card.queue_free()
