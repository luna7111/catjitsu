extends Node2D

# Layer to check with raycast
const COLLISION_MASK_CARD = 1
const COLLISION_MASK_SLOT = 2

# Speed of card returning to hand
const DEFAULT_MOVE_CARD_SPEED = 0.2

# Size factor for hover effect. 
const DEFAULT_CARD_SCALE = 1 # Set as same scale that card
const DEFAULT_CARD_SCALE_SMALL = DEFAULT_CARD_SCALE * 0.8
const DEFAULT_CARD_SCALE_BIG = DEFAULT_CARD_SCALE * 1.05

@onready var player = $"../Player"
@onready var battle_manager = $"../BattleLogic/BattleManager"

# Get Screen size for clamp function
var screen_size

# The card selected via mouse or keyboard
var selected_card

# Selects a card being dragged
var card_being_dragged

# Points to card being hovered
var card_being_hovered

# Check if we are already hovering
var is_hovering_on_card


# Tells if a monster has been played this turn
var player_monster_card_this_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player.input_manager.connect("left_mouse_button_released", on_left_click_released)

# If there's a card being dragged, it updates it's position to mouse position
func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x), 
			clamp(mouse_pos.y, 0, screen_size.y))

# Drag and drop logic

# Responsable for drag animation and show the player_slot
func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(DEFAULT_CARD_SCALE_SMALL, DEFAULT_CARD_SCALE_SMALL)
	player.slot.visible = true
	player.slot.get_node("Border/AnimationPlayer").play("pulse")

# Where the player drops the card. If it's player slot and it's empty, play that card
func finish_drag():
	if card_being_dragged:
		card_being_dragged.scale = Vector2(DEFAULT_CARD_SCALE_BIG, DEFAULT_CARD_SCALE_BIG)
		var card_slot_found = raycast_check_for_card_slot()
		if card_slot_found and not card_slot_found.card_in_slot:
			play_card(card_being_dragged, card_slot_found)
		else:
			player.hand.add_card_to_hand(card_being_dragged, DEFAULT_MOVE_CARD_SPEED)
		card_being_dragged = null
		player.slot.visible = false

# Main function to refactor
# Removes the card from the player, put its in the slot and servers to the battle manager
func play_card(card, card_slot):
	if !player_monster_card_this_turn:
		player.hand.remove_card_from_hand(card)
		player.hand.animate_card_to_position(
			card, 
			card_slot.position, 
			DEFAULT_MOVE_CARD_SPEED)
		card.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot.card_in_slot = true
		player_monster_card_this_turn = true
		battle_manager.player_card_on_slot = card
		await battle_manager.play_turn()

# Traces a ray in the 2D plane and checks for an Anrea2D of a CardSlot
func raycast_check_for_card_slot():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_SLOT
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null

# Traces a ray in the 2D plane and checks for an Area2D of a Card
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return get_card_with_highest_z_index(result)
	return null

# If two cards are stacked, retrieves card with highets z
func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
				highest_z_card = current_card
				highest_z_index = highest_z_card.z_index
	return highest_z_card

# Connects the signals for Collision2D in Card
func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

# Checks if we are on a hovered card and increases size
func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		card_being_hovered = card
		highlight_card(card, true)

# Checks if we are not longer on a hovered card, also checks for stacks
func on_hovered_off_card(card):
	if !card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered and new_card_hovered != card:
			highlight_card(new_card_hovered, true)
		else :
			is_hovering_on_card = false

# If a card is hovered, increases it size
func highlight_card(card, hovered):
	if hovered:
		if !card.is_highlighted:
			card.scale = Vector2(DEFAULT_CARD_SCALE_BIG, DEFAULT_CARD_SCALE_BIG)
			card.is_highlighted = true
		card.z_index = 2
	else:
		card.scale = Vector2(DEFAULT_CARD_SCALE, DEFAULT_CARD_SCALE)
		card.is_highlighted = false
		card.z_index = 1

func on_left_click_released():
	finish_drag()

func reset_played_monster():
	player_monster_card_this_turn = false

func select_card(card):
	if selected_card == card:
		return
	if selected_card:
		highlight_card(selected_card, false)
	selected_card = card
	if selected_card:
		highlight_card(selected_card, true)
