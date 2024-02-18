extends Node2D

var bubble_list:Array
var bubble_chain_list:Array
var chain_count:=0
var chain_total_size:=0
var chain_max_size:=0
var is_chain_done :=false # 当前泡泡链是否已经结束了
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
			clean_chain_bubble()
			is_chain_done = false

func add_bubble(bubble):
	bubble_list.append(bubble)

func remove_bubble(bubble):
	bubble_list.erase(bubble)

func add_chain_bubble(bubble):
	chain_total_size += bubble.size
	chain_max_size = max(chain_max_size,bubble.size)
	chain_count += 1
	get_tree().call_group("combo","combo_frame",chain_count)
	bubble_chain_list.append(bubble)
	
func remove_chain_bubble(bubble): # 只是个防御处理
	bubble_chain_list.erase(bubble)

func clean_chain_bubble():
	chain_total_size = 0
	chain_max_size = 0
	chain_count = 0
	get_tree().call_group("combo","combo_frame",0)
	for bubble in bubble_chain_list:
		bubble.clear_chain_info()
		bubble.call_deferred("disappear")
	bubble_chain_list.clear()
	
