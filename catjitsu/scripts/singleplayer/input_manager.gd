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
var select_card_index = -1
var select_card_object

func _ready() -> void:
	card_manager_reference = $"../../CardManager"
	deck_reference = $"../PlayerDeck"
	player_hand_reference = $"../PlayerHand"

func _input(event):	
	# Checks for left mouse input, and if it happens on a card, it selects it
	if event is InputEventMouseMotion and input_mode != INPUTMODE.MOUSE:
		change_input_to_mouse()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("left_mouse_button_clicked")
				raycast_at_cursor()
			else:
				emit_signal("left_mouse_button_released")
	if event is InputEventKey and input_mode != INPUTMODE.KEYBOARD:
		change_input_to_keyboard()

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
	card_manager_reference.on_hovered_off_card(select_card_object)
	await card_manager_reference.play_card (
		select_card_object,
		$"../PlayerCardSlot")

func change_input_to_mouse():
	input_mode = INPUTMODE.MOUSE
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	if select_card_index != -1:
		card_manager_reference.on_hovered_off_card(select_card_object)
		select_card_index = -1
	
func change_input_to_keyboard():
	input_mode = INPUTMODE.KEYBOARD
	if card_manager_reference.card_being_hovered:
		select_card_object = card_manager_reference.card_being_hovered
		select_card_index = card_manager_reference.card_being_hovered.in_hand_index
	else:
		select_card_object = null
		select_card_index = -1
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func iterate_left_player_hand():
		if select_card_index == -1:
			select_card_index = player_hand_reference.player_hand.size() - 1
			select_card_object = player_hand_reference.player_hand[select_card_index]
			card_manager_reference.on_hovered_over_card(select_card_object)
			select_card_index = select_card_object.in_hand_index
		else:
			card_manager_reference.on_hovered_off_card(select_card_object)
			if select_card_index < player_hand_reference.player_hand.size() - 1:
				select_card_index += 1
			else:
				select_card_index = 0
		select_card_object = player_hand_reference.player_hand[select_card_index]
		card_manager_reference.on_hovered_over_card(select_card_object)

func iterate_right_player_hand():
	if select_card_index == -1:
			select_card_index = player_hand_reference.player_hand.size() - 1
			card_manager_reference.on_hovered_over_card(player_hand_reference.player_hand[select_card_index])
			select_card_object = player_hand_reference.player_hand[select_card_index]
	else:
		card_manager_reference.on_hovered_off_card(select_card_object)
		if select_card_index > 0:
			select_card_index -= 1
		else:
			select_card_index = player_hand_reference.player_hand.size() - 1
		select_card_object = player_hand_reference.player_hand[select_card_index]
		card_manager_reference.on_hovered_over_card(select_card_object)

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
				card_manager_reference.start_drag(card_found)
		elif result_collision_mask == COLLISION_MASK_DECK: # Deck clicked
			deck_reference.draw_card()
