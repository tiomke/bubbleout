extends Node2D

var state:=0

func _input(event):
	if Input.is_action_pressed("ui_accept") and state==0:
		state=1
		$"CoverPage".visible=false
		$"Gameplay".visible=true
		$"Gameplay".is_ready = false
		$"Gameplay/Timer".start()
		$"Gameplay/Timer2".start()
		
