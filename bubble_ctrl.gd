extends Node2D


var bubble_list:Array
var bubble_chain_list:Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			clean_chain_bubble()
	
func add_bubble(bubble):
	bubble_list.append(bubble)

func remove_bubble(bubble):
	bubble_list.erase(bubble)

func add_chain_bubble(bubble):
	bubble_chain_list.append(bubble)

func clean_chain_bubble():
	for bubble in bubble_chain_list:
		bubble.clear_chain_info()	
	bubble_chain_list.clear()
	
