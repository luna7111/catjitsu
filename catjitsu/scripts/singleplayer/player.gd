extends Node2D

var controller
@onready var hand = $PlayerHand
@onready var deck = $PlayerDeck
@onready var slot = $PlayerCardSlot
@onready var input_manager = $InputManager

func choose_card():
	return await controller.choose_card()

func draw_card():
	deck.draw_card()

func play_card(card):
	hand.remove_card_from_hand(card)
	# This will need more logic

func end_turn():
	# Also need to reset monster played this turn
	deck.reset_draw()

func has_cards_on_deck():
	deck.has_cards()

func has_cards_on_hand():
	hand.has_cards()
