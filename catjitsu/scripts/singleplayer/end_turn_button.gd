extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var center_x = get_viewport().get_visible_rect().size.x / 2
	var center_y = get_viewport().get_visible_rect().size.y / 2
	position = Vector2(center_x, center_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
