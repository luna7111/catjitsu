extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var lowpass_effect: AudioEffect = AudioServer.get_bus_effect(1, 0)
	lowpass_effect.set("cutoff_hz", 10000)
	## Just for testing, remove when exporting to web
	##DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
