extends Node2D

var is_ready:= false

func _on_timer_timeout():
	is_ready = true
	pass


func _on_timer_2_timeout():
	get_node("BubbleSpawner").start()
	pass
