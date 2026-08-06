extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.settings_changed.connect(_change_volume)
	pass # Replace with function body.

func _change_volume():
	print(Global.config.volume)
	if (Global.config.volume == 0):
		volume_db = -80
	else:
		volume_db = (Global.config.volume - 70) / 5
