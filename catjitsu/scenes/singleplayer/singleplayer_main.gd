extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Just for testing, remove when exporting to web
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
