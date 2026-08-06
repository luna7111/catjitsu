extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
#Albeith Deck Collision mask is set to 3, it shows 4 in _ready()
const COLLISION_MASK_DECK = 4 

# Input mode enum / signal
enum INPUTMODE {
	MOUSE,
	KEYBOARD,
	CONTROLLER
}
var input_mode = INPUTMODE.MOUSE
signal input_mode_changed(mode)

var input_ui_reference
var card_manager_reference
var player_deck_reference
var player_hand_reference
var player

func _ready() -> void:
	card_manager_reference = $"../CardManager"
	player_deck_reference = $"../PlayerDeck"
	player_hand_reference = $"../PlayerHand"
	input_ui_reference = $"../InputUI"
	player = $".."

# Input selection logic
func _process(_delta: float) -> void:
	# Quit game
	if Input.is_action_just_pressed("ui_cancel"):
		#Game lost
		Global.scene_manager.switch_scene("res://scenes/main_menu/menu_home.tscn", false)
	# Iterate player hand
	if Input.is_action_just_pressed("ui_right"):
		iterate_right_player_hand()
	if Input.is_action_just_pressed("ui_left"):
		iterate_left_player_hand()
	if Input.is_action_just_pressed("ui_select"):
		play_card_keyboard()

func _input(event):	
	# Checks for left mouse input, and if it happens on a card, it selects it
	if event is InputEventMouseMotion and event.relative.length_squared() > 1:
		set_input_mode(INPUTMODE.MOUSE)
	elif event is InputEventMouseButton:
		set_input_mode(INPUTMODE.MOUSE)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("left_mouse_button_clicked")
				raycast_at_cursor()
			else:
				emit_signal("left_mouse_button_released")
	elif event is InputEventKey:
		set_input_mode(INPUTMODE.KEYBOARD)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		set_input_mode(INPUTMODE.CONTROLLER)

func set_input_mode(mode):
	if input_mode == mode:
		return
	input_mode = mode
	input_mode_changed.emit(mode)
	match  mode:
		INPUTMODE.MOUSE:
			change_input_to_mouse()
		INPUTMODE.KEYBOARD:
			change_input_to_keyboard()
		INPUTMODE.CONTROLLER:
			change_input_to_controller()

# Controller / keyboard logic 
func change_input_to_keyboard():
	if not card_manager_reference.selected_card:
		var card = card_manager_reference.card_being_hovered
		if card:
			card_manager_reference.select_card(card)
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func change_input_to_controller():
	if not card_manager_reference.selected_card:
		var card = card_manager_reference.raycast_check_for_card()
		if card:
			card_manager_reference.select_card(card)
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func iterate_left_player_hand():
	var hand = player_hand_reference.player_hand
	if hand.is_empty():
		return
	var index = -1
	if card_manager_reference.selected_card:
		index = (card_manager_reference.selected_card.in_hand_index + 1) % hand.size()
	card_manager_reference.select_card(hand[index])

func iterate_right_player_hand():
	var hand = player_hand_reference.player_hand

	if hand.is_empty():
		return

	var index = -1

	if card_manager_reference.selected_card:
		index = (card_manager_reference.selected_card.in_hand_index - 1 + hand.size()) % hand.size()
	card_manager_reference.select_card(hand[index])

func play_card_keyboard():
	if not card_manager_reference.selected_card:
		return
	var card = card_manager_reference.selected_card
	card_manager_reference.select_card(null)
	await player.play_card(card, player.slot)

# Mouse logic
func change_input_to_mouse():
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	card_manager_reference.select_card(null)

# Throws a raycast and determines if there's a card or deck under cursor
# In case of card, calls to card_manager_reference.select_card() / play_card()
func raycast_at_cursor():
	
	# Cast a ray in the 2D plane and checks for a collision mask
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	
	# If there's a collision mask, check if it was a card or a deck
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask

		# Card clicked
		if result_collision_mask == COLLISION_MASK_CARD: 
			var card_found = result[0].collider.get_parent()
			if card_found:
				pass
				card_manager_reference.start_drag(card_found)

		 # Deck clicked, right now not at use
		elif result_collision_mask == COLLISION_MASK_DECK:
			player_deck_reference.draw_card()
