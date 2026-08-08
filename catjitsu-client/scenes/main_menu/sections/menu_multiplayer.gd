extends CanvasLayer

@onready var host_button = $MarginContainer/HBoxContainer/VBoxContainer2/CreateRoomButton
@onready var join_button = $MarginContainer/HBoxContainer/VBoxContainer/JoinRoomButton
@onready var play_button = $MarginContainer/HBoxContainer/PlayGameButton
@onready var back_button = $Back
@onready var room_code_input = $MarginContainer/HBoxContainer/VBoxContainer/LineEdit
@onready var room_code_text = $MarginContainer/HBoxContainer/VBoxContainer2/RoomCode
@onready var copy_button = $MarginContainer/HBoxContainer/VBoxContainer2/CopyButton
@onready var lobby = $Lobby

signal back_pressed

# Rooms version
func _ready():
	get_tree().current_scene.input_mode_changed.connect(_on_input_mode_changed)
		
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	#back_button.pressed.connect(_on_back_pressed)
	play_button.disabled = true
	copy_button.disabled = true
	copy_button.visible = false
	copy_button.pressed.connect(_on_copy_pressed)
	room_code_text.visible = false

func _on_host_pressed():
	lobby.host_game()
	var room_code = await NetworkAPI.room_created
	room_code_text.visible = true
	room_code_text.text = "Room Code: " + room_code
	copy_button.visible = true
	copy_button.disabled = false


func _on_join_pressed():
	var room_code = room_code_input.text.strip_edges().to_upper()
	if room_code == "":
		return
	lobby.join_room(room_code)


func _on_copy_pressed():
	DisplayServer.clipboard_set(NetworkAPI.current_room_code)
	print("Room code copied!")


func _on_back_pressed():
	lobby.leave_room()
	room_code_text.visible = false
	room_code_text.text = ""
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
			if (previous == Global.InputMode.MOUSE and not $MarginContainer/HBoxContainer/VBoxContainer/LineEdit.has_focus()):
				$Dummy.grab_focus()
		Global.InputMode.CONTOLLER:
			print("Controller")
			if (previous == Global.InputMode.MOUSE):
				$Dummy.grab_focus()


func _on_visibility_changed() -> void:
	if visible and Global.current_input_mode != Global.InputMode.MOUSE:
		$Dummy.grab_focus()
		print("AAA")


func _on_create_room_button_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/HBoxContainer/VBoxContainer2/CreateRoomButton.text), Global.tts_voice)


func _on_copy_button_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/HBoxContainer/VBoxContainer2/CopyButton.text), Global.tts_voice)


func _on_play_game_button_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/HBoxContainer/PlayGameButton.text), Global.tts_voice)


func _on_line_edit_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/HBoxContainer/VBoxContainer/LineEdit.placeholder_text), Global.tts_voice)


func _on_join_room_button_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($MarginContainer/HBoxContainer/VBoxContainer/JoinRoomButton.text), Global.tts_voice)


func _on_back_focus_entered() -> void:
	if DisplayServer.accessibility_screen_reader_active() and Global.config.screenreader and Global.tts_avaiable:
		DisplayServer.tts_stop()
		DisplayServer.tts_speak(TranslationServer.tr($Back.text), Global.tts_voice)
