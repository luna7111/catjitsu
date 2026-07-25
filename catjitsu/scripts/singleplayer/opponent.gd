extends Node2D

var controller

# Expose interface
@onready var hand = $OpponentHand
@onready var slot = $OpponentCardSlot
@onready var deck = $OpponentDeck
@onready var controller_ai = $OpponentAI
#@onready var controller_network = $OpponentNetwork


func choose_card():
	return await controller.choose_card()

func play_card(card):
	hand.remove_card_from_hand(card)
