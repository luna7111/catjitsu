extends CanvasLayer


signal back_pressed
signal avatar_selection_changed

var profile_selection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	get_tree().current_scene.input_mode_changed.connect(_on_input_mode_changed)
	
	$MarginContainer/VBoxContainer/ChangeName.text = Global.profile.name
	
	profile_selection = $MarginContainer/VBoxContainer/AvatarSelection
	
	for av in Global.avatar_list:
		profile_selection.add_item(av)
	for n in profile_selection.item_count:
		if profile_selection.get_item_text(n) == Global.profile.avatar:
			profile_selection.select(n)


func _on_back_button_pressed() -> void:
	emit_signal("back_pressed")


func _on_input_mode_changed(mode: Variant, previous: Variant) -> void:
	print ("input_mode_changed")
	if not visible:
		return
	match mode:
		Global.InputMode.MOUSE:
			print("mouse")
			if (previous != Global.InputMode.MOUSE):
				$Dummy.grab_focus()
				$Dummy.release_focus()
		Global.InputMode.KEYBOARD:
			print("keyboard")
			if (previous == Global.InputMode.MOUSE):
				$Dummy.grab_focus()
		Global.InputMode.CONTOLLER:
			print("Controller")
			if (previous == Global.InputMode.MOUSE):
				$Dummy.grab_focus()


func _on_visibility_changed() -> void:
	if visible and Global.current_input_mode != Global.InputMode.MOUSE:
		$Dummy.grab_focus()


func _on_avatar_selection_selection_changed() -> void:
	var item_id = profile_selection.selected
	Global.profile.avatar = profile_selection.get_item_text(item_id)
	avatar_selection_changed.emit()
