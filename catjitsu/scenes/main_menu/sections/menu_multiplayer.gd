extends CanvasLayer

@onready var host_button = $MarginContainer/HBoxContainer/VBoxContainer2/Button
@onready var join_button = $MarginContainer/HBoxContainer/VBoxContainer/Button
@onready var play_button = $MarginContainer/HBoxContainer/PlayGameButton
@onready var back_button = $Back
@onready var room_code_input = $MarginContainer/HBoxContainer/VBoxContainer/LineEdit
@onready var room_code_text = $MarginContainer/HBoxContainer/VBoxContainer2/RoomCode
@onready var copy_button = $MarginContainer/HBoxContainer/VBoxContainer2/CopyButton
@onready var lobby = $Lobby

signal back_pressed

# Rooms version
func _ready():
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
	emit_signal("back_pressed")
