extends Control
@onready var input_manager_reference = $"../InputManager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input_manager_reference.input_mode_changed.connect(_on_input_mode_changed)
	$Input/Mouse.visible = true

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_input_mode_changed(mode):
	match mode:
		input_manager_reference.INPUTMODE.MOUSE:
			$Input/Keyboard.visible = false
			$Input/Controller.visible = false
			$Input/Mouse.visible = true
		input_manager_reference.INPUTMODE.KEYBOARD:
			$Input/Keyboard.visible = true
			$Input/Controller.visible = false
			$Input/Mouse.visible = false
		input_manager_reference.INPUTMODE.CONTROLLER:
			$Input/Keyboard.visible = false
			$Input/Controller.visible = true
			$Input/Mouse.visible = false
