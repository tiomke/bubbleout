extends Node2D

var state:=0

func _ready():
	$"FailPage".visible=false
	$"CoverPage".visible=true
	$"Gameplay".visible=false
	$"Gameplay".is_ready = false
	
func _input(event):
	if Input.is_action_pressed("ui_accept") and state==0:
		start()
func gameover():
	state = 0
	$"FailPage".visible=true
	$"CoverPage".visible=false
	$"Gameplay".visible=true
	$"Gameplay".is_ready = false
	$"Gameplay/Timer".stop()
	$"Gameplay/Timer2".stop()
	$"Gameplay/BubbleSpawner".stop()
	$"Score".gameover()
		
func start():
	state=1
	$"FailPage".visible=false
	$"CoverPage".visible=false
	$"Gameplay".visible=true
	$"Gameplay".is_ready = false
	$"Gameplay".start()
	
		
