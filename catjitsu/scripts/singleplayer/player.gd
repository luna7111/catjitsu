extends Node2D

var controller
#var deck_data
@onready var hand = $PlayerHand
@onready var deck = $PlayerDeck
@onready var slot = $PlayerCardSlot
@onready var input_manager = $InputManager
@onready var card_manager = $CardManager

# Card logic
signal card_played(card)

var monster_played_this_turn = false

func setup(deck_data):
	deck.setup(deck_data)

func choose_card():
	return await controller.choose_card()

func draw_card():
	deck.draw_card()

func play_card(card, card_slot):
	if monster_played_this_turn:
		return false
	hand.remove_card_from_hand(card)
	hand.animate_card_to_position(
		card,
		card_slot.position,
		0.2
	)
	card.get_node("Area2D/CollisionShape2D").disabled = true
	card_slot.card_in_slot = true
	monster_played_this_turn = true
	card_played.emit(card)

func end_turn():
	# Also need to reset monster played this turn
	monster_played_this_turn = false
	slot.card_in_slot = false
	deck.reset_draw()
	if deck.has_cards():
		deck.draw_card()

func has_cards_on_deck():
	return deck.has_cards()

func has_cards_on_hand():
	return hand.has_cards()
