extends CanvasLayer


signal back_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for av in Global.avatar_list:
		$MarginContainer/VBoxContainer/ProfileOptions.add_item(av)
	for n in $MarginContainer/VBoxContainer/ProfileOptions.item_count:
		if $MarginContainer/VBoxContainer/ProfileOptions.get_item_text(n) == Global.profile.avatar:
			$MarginContainer/VBoxContainer/ProfileOptions.select(n)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	var item_id = $MarginContainer/VBoxContainer/ProfileOptions.get_selected_id()
	Global.profile.avatar = $MarginContainer/VBoxContainer/ProfileOptions.get_item_text(item_id)
	emit_signal("back_pressed")
