extends Node2D

var card_in_slot = false

var middle_screen_x
var top_screen_y

func _ready():
	middle_screen_x = get_viewport().size.x / 2 - 210
	top_screen_y = get_viewport().size.y / 2
	position = Vector2(middle_screen_x, top_screen_y)
