extends Node2D

#Load JSON DAta
var JSON_PATH_FOLDER = "res://card_database/"

#Speed for Deck to move to its initial position
const INITIAL_DECK_SPEED = 0.5

#Speed to draw a card
const CARD_DRAW_SPEED = 0.2

# Reference to player_hand
var player_hand_reference

# Setup Deck
const CARD_SCENE_PATH = "res://scenes/singleplayer/player_card.tscn"
const STARTING_HAND_SIZE = 5
var player_deck = ["World", "World", "World", "Priestess", "Priestess", "Priestess", "Fool", "Fool", "Fool"]
var quarter_screen_x
var bottom_screen_y

# Draw card logic per turn
var drawn_card_this_turn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_deck.shuffle()
	player_hand_reference = $"../PlayerHand"
	$RichTextLabel.text = str(player_deck.size())
	await animate_deck_to_position()
	for i in range(STARTING_HAND_SIZE):
		draw_card()
		drawn_card_this_turn = false
	drawn_card_this_turn = true

func animate_deck_to_position():
	quarter_screen_x = get_viewport().get_visible_rect().size.x / 10 * 9
	bottom_screen_y = get_viewport().get_visible_rect().size.y / 10 * 9
	var tween = get_tree().create_tween()
	tween.tween_property(
		self, 
		"position", 
		Vector2(quarter_screen_x, bottom_screen_y), 
		INITIAL_DECK_SPEED)
	await tween.finished

# Main function. Draws a card from the deck and add it to the player_hand
func draw_card():
	# logic check
	if drawn_card_this_turn or player_deck.size() == 0:
		return
	
	# Erase card from the deck
	drawn_card_this_turn = true
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	# If the deck is empty, hide deck. Else update deck count
	if player_deck.size() == 0:
		$Area2D/CollisionShape2D.disabled = true
		$CardBack.visible = false
		$RichTextLabel.visible = false
	$RichTextLabel.text = str(player_deck.size())
	
	# Instantiate a card scene
	var card_scene = preload(CARD_SCENE_PATH)
	var new_card = card_scene.instantiate() 
	
	#Load JSON DATA
	load_card_data(new_card, card_drawn)
	$"../../CardManager".add_child(new_card)
	new_card.name = "CARD"
	
	# Add card to the hand of the player
	player_hand_reference.add_card_to_hand(new_card, CARD_DRAW_SPEED)
	new_card.get_node("AnimationPlayer").play("card_flip")	

func load_card_data(new_card, card_drawn):
	# Open the file and check if it exists
	var file_path = JSON_PATH_FOLDER + card_drawn + ".json"
	assert(FileAccess.file_exists(file_path), "File path doest not exist")
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	# Read the content of the file as text and parse
	var json = file.get_as_text()
	var json_object = JSON.new()
	json_object.parse(json)
	
	# Load the data of the card
	var card_data = json_object.data
	var card_image_path = str("res://assets/singleplayer/cards_images/" + card_drawn + "Card.png")
	print(card_image_path)
	new_card.points = int(card_data["value"])
	new_card.get_node("Points").text = str(new_card.points)
	set_card_data_type(new_card, card_data["type"])
	new_card.get_node("CardFront/CardCatSprite").texture = load(card_image_path)
	new_card.get_node("Type").texture = load("res://assets/singleplayer/elements_icons/" + new_card.type + ".png")

func set_card_data_type(drawn_card, type):
	var panel = drawn_card.get_node("CardFront")
	var style = panel.get_theme_stylebox("panel").duplicate()
	panel.add_theme_stylebox_override("panel", style)

	drawn_card.type = type

	# Change color of cards. Must be identical that opponent_deck
	match type:
		"Fire":
			style.bg_color = Color("f4dbc2")
			style.border_color = Color("dcc197")
		"Water":
			style.bg_color = Color("d0d0f6")
			style.border_color = Color("a897dc")
		"Ice":
			style.bg_color = Color("e7f2f9")
			style.border_color = Color("c1daec")

func reset_draw():
	drawn_card_this_turn = false

func has_cards():
	return player_deck.size() > 0
