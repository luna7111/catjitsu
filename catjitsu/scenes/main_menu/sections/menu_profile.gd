extends CanvasLayer


signal back_pressed
signal avatar_selection_changed

var profile_selection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	get_tree().current_scene.input_mode_changed.connect(_on_input_mode_changed)
	
	$MarginContainer/VBoxContainer/DisplayName.text = Global.profile.name
	
	profile_selection = $MarginContainer/VBoxContainer/AvatarSelection
	
	for av in Global.avatar_list:
		profile_selection.add_item(av)
	for n in profile_selection.item_count:
		if profile_selection.get_item_text(n) == Global.profile.avatar:
			profile_selection.select(n)


func _on_back_button_pressed() -> void:
	var url = "http://localhost:8000/player/" + str(Global.profile.id).pad_decimals(0) + "/avatar"
	var headers = ["Content-Type: application/json"]
	if Global.api.access_token != "":
		headers.append("Authorization: Bearer " + Global.api.access_token)
	var body = "{\"avatar\": \"" + Global.profile.avatar + "\"}"
	$HTTP/UpdateAvatar.request_completed.connect(_on_update_avatar_completed)
	$HTTP/UpdateAvatar.request(url, headers, HTTPClient.METHOD_PUT, body)
	emit_signal("back_pressed")

func _on_update_avatar_completed(result, response_code, headers, body):
	print("update avatar response:")
	print(response_code)
	var pr = JSON.parse_string(body.get_string_from_utf8())
	if typeof(pr) == TYPE_DICTIONARY:
		print(pr)
	elif pr.error == OK:
		print(pr.result)
	else:
		print("could not parse response")


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
