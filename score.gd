extends Node2D

@onready var hp_bar = %HpBar
@onready var clock_table :Sprite2D= %ClockTable
@onready var main = $".."
@onready var game_over = $game_over

# 分数统计
# 当场景内出现半径很大的负面泡泡时，扣除一个爱心
# 清除负面泡泡会往天晴移动
# 负面泡泡变大，会往天阴移动
var hp_max := 1
var hp := hp_max
var score_min:=-18
var score:= 0 # 最高0分，最低-18分

func _ready():
	prints("score _ready",hp_bar,clock_table)
	pass
	
func gameover():
	reset()
func reset():
	hp = hp_max
	score = 0
	
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
	clock_table.rotation_degrees = get_clock_rotation()
	prints("sub_score",score,clock_table.rotation_degrees)
	
func add_score(delta=1):
	score += delta
	clock_table.rotation_degrees = get_clock_rotation()
	prints("add_score",score,clock_table.rotation_degrees)

# 0 - -180 degree 0 sun -90 cloudy -180 rain
func get_clock_rotation():
	score = max(score_min,min(0,score))
	return score*10+180 # 180是初始偏移角度
	
	
	
	


