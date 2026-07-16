extends Node2D

@onready var opponent_hand_reference = $"../OpponentHand"
var opponent_hand

func _ready() -> void:
	opponent_hand = opponent_hand_reference.opponent_hand

func choose_card():
	# In the future we could implement a dificulty selector here
	return await try_play_card_highest_attack()

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
