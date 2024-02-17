extends Timer

@onready var gameplay = $".."
@export var spawn_rate:float=0.5
@export var spawn_size_min:int=2 # 半径为16*size
@export var spawn_size_max:int=4 # 半径为16*size
@export var negtive_max_minute:float= 10 # 消极泡泡10分钟后难度达到最大
@export var negtive_max_rate:float=0.7 # 消极泡泡最高占比

var acc_count = 0
var bubble_scene = preload("res://bubble.tscn")
	
func _init():
	randomize()
	
func _on_timeout():
	acc_count += 1
	random_spawn()
	
func reset():
	acc_count = 0
	
func random_spawn():
	if randf() > spawn_rate:
		return
	var new_bubble = bubble_scene.instantiate()
	new_bubble.position.x = -16*10
	new_bubble.position.y = randi_range(0,gameplay.get_viewport_rect().size.y)
	gameplay.add_child(new_bubble)
	var total_count = negtive_max_minute*60/wait_time
	var nag_rate:float = negtive_max_rate * max(0.2,minf(acc_count / total_count,1))
	var bubble_script = new_bubble as Bubble
	# 设置基础配置，同时加上随机偏移
	if randf() < nag_rate:
		bubble_script.bubble_type = Bubble.BubbleType.Negtive
	bubble_script.size = randi_range(spawn_size_min,spawn_size_max)
	bubble_script.speed *= randf_range(0.8, 1.2) # 随机调整速度
	prints("random_spawn>>bubble_type",bubble_script.get_color(),bubble_script.bubble_type)
	bubble_script.reset_state()
