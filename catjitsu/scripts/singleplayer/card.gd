extends Node2D

# Signals to send to parent
signal hovered
signal hovered_off

# Check if a card is already highlighted
var is_highlighted = false
var in_hand_position
var in_hand_index

# Card Position
var quarter_screen_x
var bottom_screen_y

# Card Data, read from JSON
var points
var type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Must be set as same position as player_deck
	quarter_screen_x = get_viewport().size.x / 10 * 9
	bottom_screen_y = get_viewport().size.y / 6 * 5
	position = Vector2(quarter_screen_x, bottom_screen_y)
	get_parent().connect_card_signals(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
 
# Emits a signal when card is hovered
func _on_area_2d_mouse_entered() -> void:
	emit_signal("hovered", self)

# Emits a signal when card is hovered off
func _on_area_2d_mouse_exited() -> void:
		emit_signal("hovered_off", self)
