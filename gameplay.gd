extends Node2D

var is_ready:= false
@onready var bubble_spawner = $BubbleSpawner

func start():
	$"Timer".start()
	$"Timer2".start()
	reset()
	
func gameover():
	bubble_spawner.gameover()
	
func reset():
	BubbleCtrl.reset()
	bubble_spawner.init_spawn()
	
func _on_timer_timeout():
	is_ready = true
	pass


func _on_timer_2_timeout():
	get_node("BubbleSpawner").start()
	pass
