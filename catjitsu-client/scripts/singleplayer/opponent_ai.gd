extends Node2D

@onready var opponent_hand_reference = $"../OpponentHand"
@onready var battle_manager = $"../../BattleLogic/BattleManager"
var opponent_hand
const BLUFF_CHANCE := 0.25

func _ready() -> void:
	opponent_hand = opponent_hand_reference.opponent_hand

# New implementatino
func choose_card():
	var target = choose_element()
	if target == "":
		return try_play_card_highest_attack()
	if should_bluff(target):
		return play_highest_of_element(counter_prediction(target))
	return play_highest_of_element(target)

func choose_element():
	if player_is_winning():
			return choose_defensive()
	return choose_aggressive()
		
func choose_aggressive():
	var target_element = ""

	# 1. Can I win with 3 of the same element?
	target_element = get_element_with_points(
		battle_manager.opponent_points,
		2
	)
	if target_element != "":
		return target_element

	# 2. Can I complete the 3 different elements victory?
	target_element = get_missing_element(
		battle_manager.opponent_points
	)
	if target_element != "":
		return target_element

	# 3. Can the player win with 3 of the same element?
	target_element = get_element_with_points(
		battle_manager.player_points,
		2
	)
	if target_element != "":
		return defeat_element(target_element)

	# 4. Can the player complete the 3 different elements victory?
	target_element = get_missing_element(
		battle_manager.player_points
	)
	if target_element != "":
		return defeat_element(target_element)

	return ""

func choose_defensive():
	var target_element = ""

	# 1. Can the player win with 3 of the same element?
	target_element = get_element_with_points(
		battle_manager.player_points,
		2
	)
	if target_element != "":
		return defeat_element(target_element)

	# 2. Can the player complete the 3 different elements victory?
	target_element = get_missing_element(
		battle_manager.player_points
	)
	if target_element != "":
		return defeat_element(target_element)

	# 3. Can I win with 3 of the same element?
	target_element = get_element_with_points(
		battle_manager.opponent_points,
		2
	)
	if target_element != "":
		return target_element

	# 4. Can I complete the 3 different elements victory?
	target_element = get_missing_element(
		battle_manager.opponent_points
	)
	if target_element != "":
		return target_element
	return ""


func get_element_with_points(points_dictionary, amount):
	for element in ["Fire", "Water", "Ice"]:
		if points_dictionary[element] == amount:
			return element
	return ""

func get_missing_element(points_dictionary):
	var elements = []
	for element in ["Fire", "Water", "Ice"]:
		if points_dictionary[element] > 0:
			elements.append(element)
	if elements.size() != 2:
		return ""
	for element in ["Fire", "Water", "Ice"]:
		if !elements.has(element):
			return element
	return ""

func defeat_element(target_element):
	match target_element:
		"Fire":
			return "Water"
		"Water":
			return "Ice"
		"Ice":
			return "Fire"

func counter_prediction(element):
	match element:
		"Fire":
			return "Ice"
		"Water":
			return "Fire"
		"Ice":
			return "Water"
	return ""

func play_highest_of_element(element):
	var best_card = null
	for card in opponent_hand:
		if card.type != element:
			continue
		if best_card == null or card.points > best_card.points:
			best_card = card
	if best_card == null:
		return try_play_card_highest_attack()
	return best_card

func try_play_card_highest_attack():
	# Check in bounds
	if opponent_hand.is_empty():
		return null
	# Pick highest card
	var card_with_highest_attack = opponent_hand[0]
	for card in opponent_hand:
		if card.points > card_with_highest_attack.points:
			card_with_highest_attack = card
	return card_with_highest_attack

func should_bluff(target_element):
	# We only bluff when we are attacking.
	if player_is_winning():
		return false
	# Don't bluff if we don't have the predicted counter.
	var bluff_element = counter_prediction(target_element)
	if !has_element(bluff_element):
		return false
	return randf() < BLUFF_CHANCE

func has_element(element):
	for card in opponent_hand:
		if card.type == element:
			return true
	return false

func get_score(points_dictionary):
	var score = 0
	for element in ["Fire", "Water", "Ice"]:
		score += points_dictionary[element]
	return score

func player_is_winning():
	return get_score(battle_manager.player_points) > get_score(battle_manager.opponent_points)
