extends Node2D

@onready var opponent_deck_reference = $"../OpponentDeck"
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
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate()
	opponent_deck_reference.load_card_data(new_card, received_card_name)
	get_tree().current_scene.add_child(new_card)
	received_card_name = ""
	return new_card
