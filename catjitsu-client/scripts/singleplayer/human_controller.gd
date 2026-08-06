extends Node2D

signal card_chosen(card)

@onready var card_manager = $"../CardManager"

func _ready() -> void:
	card_manager.card_selected.connect(_on_card_selected)

func choose_card():
	return await card_chosen

func _on_card_selected(card):
	card_chosen.emit(card)
