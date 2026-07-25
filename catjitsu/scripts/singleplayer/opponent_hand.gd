extends Node2D

#const HAND_COUNT = 5
#const CARD_SCENE_PATH = "res://scenes/card.tscn"

# Desired distance beewten cards. Must be card_width + wished padding
const CARD_WIDTH = 160
const HAND_Y_POSITION = 200

# Speed to draw a card
const DEFAULT_CARD_MOVE_SPEED = 0.2

var opponent_hand = []
var center_screen_x
var top_screen_y

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center_screen_x = get_viewport().get_visible_rect().size.x / 2
	top_screen_y = get_viewport().get_visible_rect().size.y / 10
	#var card_scene = preload(CARD_SCENE_PATH)
	#for i in range(HAND_COUNT):
		#var new_card = card_scene.instantiate()
		#$"../CardManager".add_child(new_card)
		#new_card.name = "CARD"
		#add_card_to_hand(new_card)

func add_card_to_hand(card, speed):
	if card not in opponent_hand:
		opponent_hand.insert(0, card)
		# Get new card position based on index passed in
		update_hand_positions()
	else:
		animate_card_to_position(card, card.in_hand_position, speed)

func has_cards():
	return opponent_hand.size() > 0

func update_hand_positions():
	if center_screen_x == null:
		center_screen_x = get_viewport().get_visible_rect().size.x / 2
	if top_screen_y == null:
		top_screen_y = get_viewport().get_visible_rect().size.y / 6
	for i in range(opponent_hand.size()):
		#var new_position = Vector2(calculate_card_position(i), HAND_Y_POSITION)
		var new_position = Vector2(calculate_card_position(i), top_screen_y)
		var card = opponent_hand[i]
		card.in_hand_position = new_position
		animate_card_to_position(card, new_position, DEFAULT_CARD_MOVE_SPEED)

func calculate_card_position(index):
	if center_screen_x == null:
		center_screen_x = get_viewport().get_visible_rect().size.x / 2
	var total_width = (opponent_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + index * CARD_WIDTH - total_width / 2.0
	return x_offset

func animate_card_to_position(card, new_position, speed):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in opponent_hand:
			opponent_hand.erase(card)
			update_hand_positions()
