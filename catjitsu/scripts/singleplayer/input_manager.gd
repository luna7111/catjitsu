extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
#Albeith Deck Collision mask is set to 3, it shows 4 in _ready()
const COLLISION_MASK_DECK = 4 

enum INPUTMODE {
	MOUSE,
	KEYBOARD,
	CONTROLLER
}

var input_mode = INPUTMODE.MOUSE

var card_manager_reference
var deck_reference
var player_hand_reference

func _ready() -> void:
	card_manager_reference = $"../../CardManager"
	deck_reference = $"../PlayerDeck"
	player_hand_reference = $"../PlayerHand"

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
	elif event is InputEventJoypadButton:
		set_input_mode(INPUTMODE.CONTROLLER)

func set_input_mode(mode):
	if input_mode == mode:
		return
	input_mode = mode
	match  mode:
		INPUTMODE.MOUSE:
			change_input_to_mouse()
		INPUTMODE.KEYBOARD:
			change_input_to_keyboard()
		INPUTMODE.CONTROLLER:
			change_input_to_controller()
			
func _process(_delta: float) -> void:
	# Quit game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	# Iterate player hand
	if Input.is_action_just_pressed("ui_right"):
		iterate_right_player_hand()
	if Input.is_action_just_pressed("ui_left"):
		iterate_left_player_hand()
	if Input.is_action_just_pressed("ui_select"):
		play_card_keyboard()

func play_card_keyboard():
	if not card_manager_reference.selected_card:
		return
	var card = card_manager_reference.selected_card
	card_manager_reference.select_card(null)
	await card_manager_reference.play_card(card, $"../PlayerCardSlot")

#
func change_input_to_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	card_manager_reference.select_card(null)
	# Future feature, change icons
	
func change_input_to_keyboard():
	if not card_manager_reference.selected_card:
		var card = card_manager_reference.card_being_hovered
		if card:
			card_manager_reference.select_card(card)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Future feature, change icons

func change_input_to_controller():
	if not card_manager_reference.selected_card:
		var card = card_manager_reference.raycast_check_for_card()
		if card:
			card_manager_reference.select_card(card)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Future feature, change icons

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

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_mask = result[0].collider.collision_mask
		if result_collision_mask == COLLISION_MASK_CARD: # Card clicked
			var card_found = result[0].collider.get_parent()
			if card_found:
				card_manager_reference.select_card(card_found)
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK: # Deck clicked
			deck_reference.draw_card()
