extends CanvasLayer


signal back_pressed


var profile_selection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	profile_selection = $MarginContainer/VBoxContainer/OptionNavigator
	
	for av in Global.avatar_list:
		profile_selection.add_item(av)
	for n in profile_selection.item_count:
		if profile_selection.get_item_text(n) == Global.profile.avatar:
			profile_selection.select(n)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	var item_id = profile_selection.selected
	Global.profile.avatar = profile_selection.get_item_text(item_id)
	emit_signal("back_pressed")
