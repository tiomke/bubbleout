extends Node2D

@onready var hp_bar = %HpBar
@onready var clock_table :Sprite2D= %ClockTable
@onready var main = $".."
@onready var game_over = $game_over
@onready var background:Sprite2D = $"../Gameplay/Background"
@onready var rain = $"../Gameplay/Background/Rain"
@onready var cloud = $"../Gameplay/Background/cloud"
@onready var sfx_rain = $"../Gameplay/Background/Rain/rain"
@onready var sfx_cloud = $"../Gameplay/Background/cloud/cloud"

# 分数统计
# 当场景内出现半径很大的负面泡泡时，扣除一个爱心
# 清除负面泡泡会往天晴移动
# 负面泡泡变大，会往天阴移动
var init_clock_degree = 180
var hp_max := 8
var hp := hp_max
var score_min:=-18
var score:= 0 # 最高0分，最低-18分

func _ready():
	clock_table.rotation_degrees = init_clock_degree
	#prints("score _ready",hp_bar,clock_table)
	pass
	
func gameover():
	hp = hp_max
	score = 0
	
func reset():
	rain.emitting = false
	cloud.emitting = false
	sfx_rain.stop()
	sfx_cloud.stop()
	for i in hp_max:
		var texture := hp_bar.get_child(i)
		texture.visible = true
	hp = hp_max
	score = 0
	clock_table.rotation_degrees = init_clock_degree
	background.material.set("shader_parameter/day_night_factor",1)
	background.material.set("shader_parameter/day_night_factor2",0)
	
func sub_hp():
	if hp <= 0:
		return
	hp -= 1
	for i in hp_max:
		var texture := hp_bar.get_child(i)
		texture.visible = hp>=(i+1)
	if hp <= 0:
		main.gameover()
		game_over.play()
		pass
func sub_score():
	score -= 1
	on_score_change()
	#prints("sub_score",score,clock_table.rotation_degrees)
	
func add_score(delta=1):
	score += delta
	on_score_change()
	#prints("add_score",score,clock_table.rotation_degrees)

# 0 - -180 degree 0 sun -90 cloudy -180 rain
func get_clock_rotation():
	return score*10+init_clock_degree # 180是初始偏移角度
	
func on_score_change():
	score = max(score_min,min(0,score))
	var rotation = get_clock_rotation()
	clock_table.rotation_degrees = rotation
	if rotation <= init_clock_degree-180+30: # 加个偏移，还没完全到的时候就开始有了
		rain.emitting=true
		cloud.emitting=false
		sfx_rain.play()
		sfx_cloud.stop()
	elif rotation <= init_clock_degree-90+30:
		rain.emitting=false
		cloud.emitting=true
		sfx_rain.stop()
		if rotation <= init_clock_degree-90+10:
			sfx_cloud.play()
	else:
		rain.emitting=false
		cloud.emitting=false
		sfx_rain.stop()
		sfx_cloud.stop()
	var rate = -float(score)/score_min+1
	background.material.set("shader_parameter/day_night_factor",float(rate))
	background.material.set("shader_parameter/day_night_factor2",1-float(rate))
	#prints("shader value",background.material.get("shader_parameter/day_night_factor"),rate)
	
	
	
	


