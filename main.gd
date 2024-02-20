extends Node2D

var state:=0

func _ready():
	$"FailPage".visible=false
	$"CoverPage".visible=true
	$"Gameplay".visible=false
	$"Gameplay".is_ready = false
	$GuidePage.visible = false
	
func _input(event):
	if Input.is_action_pressed("ui_accept") or (Input.is_action_pressed("ui_click") and state==0):
		if state==0:
			$GuidePage.visible = true
			$"Gameplay".visible=true
			$CoverPage.visible = false
			state=1
		elif state == 1:
			start()
	
func gameover():
	state = 1
	$GuidePage.visible = false
	$"FailPage".visible=true
	$"CoverPage".visible=false
	$"Gameplay".visible=true
	$"Gameplay".is_ready = false
	$"Gameplay/Timer".stop()
	$"Gameplay/Timer2".stop()
	$"Gameplay/BubbleSpawner".stop()
	$"Score".gameover()
	$Gameplay.gameover()
		
func start():
	state=2
	$GuidePage.visible = false
	$"FailPage".visible=false
	$"CoverPage".visible=false
	$"Gameplay".visible=true
	$"Gameplay".is_ready = false
	$"Gameplay".start()
	$Score.reset()
	
		
