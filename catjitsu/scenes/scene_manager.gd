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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preload("res://scenes/main_menu/menu_home.tscn")
	preload("res://scenes/main_menu/background/main_menu_background.tscn")
	Global.scene_manager = self
	_set_startup_scene(startup_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
