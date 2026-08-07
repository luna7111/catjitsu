class_name SceneManager
extends Node
## Manager for the game scenes
##
## The SceneManager node is pointed to by the scene_manager variable in the
## Global node.
## Use Global.scene_manager.switch_scenes() to switch scenes

@export var startup_scene: PackedScene
@export var server_scene: PackedScene
var _current_scene: Node
var music_player


signal input_mode_changed(mode, previous)
signal api_up
signal api_down


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var music_player_scene = load("res://scenes/music_player.tscn")
	music_player = $MusicPlayer
	Global.scene_manager = self
	if OS.has_feature("dedicated_server"):
		print("Dedicated:", OS.has_feature("dedicated_server"))
		_set_startup_scene(load("res://scenes/server/server.tscn"))
	else:
		_set_startup_scene(startup_scene)


func _ping(result, response_code, headers, body):
	if (response_code != 0 and Global.api_working == false):
		api_up.emit()
		Global.api_working = true
	if (response_code == 0 and Global.api_working == true):
		api_down.emit()
		Global.api_working = false


func _set_startup_scene(scene):
	var new_scene = scene.instantiate()
	add_child(new_scene)
	_current_scene = new_scene


## Switches the current scene to the one in the given path.
## 
## The persistence argument defines whether the scene will be kept in memory or
## not, recurrent scenes like main menu should be kept in memory, one time
## scenes like login/register scenes shouldn't.
func switch_scene(path: String, persistence: bool):
	if not persistence:
		_current_scene.queue_free()
	else:
		remove_child(_current_scene)
	var new_scene = load(path).instantiate()
	add_child(new_scene)
	_current_scene = new_scene

func notify(text: String):
	var notification = load("res://scenes/gui_elements/user_notification.tscn").instantiate()
	notification.text = text
	$CanvasLayer/Notifications.add_child(notification)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion \
			and event.relative.length_squared() > 5000 \
			and Global.current_input_mode != Global.InputMode.MOUSE:
		emit_signal("input_mode_changed", Global.InputMode.MOUSE, Global.current_input_mode)
		Global.current_input_mode = Global.InputMode.MOUSE
	if event is InputEventMouseButton \
				and Global.current_input_mode != Global.InputMode.MOUSE:
		emit_signal("input_mode_changed", Global.InputMode.MOUSE, Global.current_input_mode)
		Global.current_input_mode = Global.InputMode.MOUSE
	elif event is InputEventKey \
			and Global.current_input_mode != Global.InputMode.KEYBOARD:
		emit_signal("input_mode_changed", Global.InputMode.KEYBOARD, Global.current_input_mode)
		Global.current_input_mode = Global.InputMode.KEYBOARD
	elif event is InputEventJoypadButton \
		and Global.current_input_mode != Global.InputMode.CONTOLLER:
		emit_signal("input_mode_changed", Global.InputMode.CONTOLLER, Global.current_input_mode)
		Global.current_input_mode = Global.InputMode.CONTOLLER
	else:
		pass
