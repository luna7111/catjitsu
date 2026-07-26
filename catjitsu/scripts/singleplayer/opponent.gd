extends Node2D

# Stablished by singleplayer.gd or multiplayer.gd
var controller

# Expose interface
@onready var hand = $OpponentHand
@onready var slot = $OpponentCardSlot
@onready var deck = $OpponentDeck

# Just to expose in case, not really used
@onready var controller_ai = $OpponentAI
#@onready var controller_network = $OpponentNetwork


func choose_card():
	return await controller.choose_card()

func play_card(card):
	hand.remove_card_from_hand(card)
	slot.card_in_slot = true
	await get_tree().create_timer(1.0).timeout

func end_turn():
	slot.card_in_slot = false
	if deck.has_cards():
		deck.draw_card()
