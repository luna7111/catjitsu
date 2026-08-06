extends Node2D

@onready var opponent_deck_reference = $"../OpponentDeck"
@onready var opponent_hand_reference = $"../OpponentHand"
const CARD_SCENE_PATH = "res://scenes/singleplayer/opponent_card.tscn"
var received_card_name = ""
signal opponent_card_ready

func _ready():
	NetworkAPI.opponent_card_received.connect(_on_opponent_card_received)

func _on_opponent_card_received(card_name):
	received_card_name = card_name
	opponent_card_ready.emit()

func choose_card():
	if received_card_name == "":
		await opponent_card_ready
	for card in opponent_hand_reference.opponent_hand:
		if card.id == received_card_name:
			received_card_name = ""
			return card
