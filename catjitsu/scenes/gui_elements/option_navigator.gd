extends HBoxContainer

var options: = []
var selected = 0
var item_count = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func add_item(item: String):
	options.append(item)
	item_count += 1


func get_item_text(id: int) -> String:
	if id >= 0 and id < item_count:
		return options[id]
	else:
		return ""


func select(id: int):
	if id >= 0 and id < item_count:
		selected = 0
	update_text()


func update_text():
	if item_count > 0:
		$Display.text = options[selected]


func _on_previous_pressed() -> void:
	selected -= 1
	if selected < 0:
		selected = item_count - 1
	update_text()


func _on_next_pressed() -> void:
	selected += 1
	if selected >= item_count:
		selected = 0
	update_text()
