extends Node2D

var controller
@onready var hand = $PlayerHand
@onready var deck = $PlayerDeck
@onready var slot = $PlayerCardSlot

func choose_card():
	return await controller.choose_card()

func play_card(card):
	hand.remove_card_from_hand(card)

func end_turn():
	deck.reset_draw()
