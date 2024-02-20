extends Node2D

class_name Bubble

enum BubbleType { Positive,Negtive }
# 配置项
#@export var color:Color
@export var bubble_type:BubbleType
@export var size:int # size*16就是半径
@export var speed:int
@export var positive_color:Color
@export var negtive_color:Color
@export var chain_color:Color
@export var max_size:=8

var _color:Color
var _radius:int
var is_destroying:bool

# 引用项
@onready var collision_shape_2d:CollisionShape2D = $Area2D/CollisionShape2D
@onready var crnt_sprite = $Area2D/Sprite
@onready var gameplay = $".."
@onready var animation_tree = $Area2D/AnimationTree
@onready var sfx_boom = $Sounds/boom
@onready var sfx_disappear_b = $Sounds/disappear_b
@onready var sfx_disappear_y = $Sounds/disappear_y
@onready var sfx_join_chain = $Sounds/join_chain
@onready var sfx_scale_down = $Sounds/scale_down
@onready var sfx_scale_up = $Sounds/scale_up
@onready var sfx_chain_fail = $Sounds/chain_fail

# 手势相关标记
var is_mouse_in_shape:=false
var is_triggered := false

# 随机移动
var random:RandomNumberGenerator
var safe_dist = Vector2.ZERO
var wave_noise := FastNoiseLite.new()
var Score
# 导出的变量，也要在 ready 后才生效
func _ready():
	
	# 独立的随机数生成器
	random = RandomNumberGenerator.new()
	random.randomize()
	init_wave_move(position)
	
	var shape = CircleShape2D.new()
	collision_shape_2d.shape = shape
	reset_state()
	crnt_sprite.rotation_degrees = random.randi_range(0,360)
	safe_dist = Vector2(_radius,_radius)
	
func reset_state():
	_radius = size*16
	collision_shape_2d.shape.radius = _radius
	_color = get_color()
	queue_redraw()
	crnt_sprite.scale.x = size
	crnt_sprite.scale.y = size
	animation_tree["parameters/conditions/is_boom"]=false
	animation_tree["parameters/conditions/is_disappear"]=false
	#prints("get_viewport_rect(),radius,frame",get_viewport_rect(),_radius,get_viewport_rect().grow(-_radius).grow_side(0,-100))

func destroy():
	BubbleCtrl.remove_bubble(self)
	BubbleCtrl.remove_chain_bubble(self)
	queue_free()

func _draw():
	#draw_circle(Vector2.ZERO, _radius, _color)
	pass
func get_color():
	if bubble_type == BubbleType.Positive:
		return positive_color
	elif bubble_type == BubbleType.Negtive:
		return negtive_color

func _process(delta):
	if not visible:
		return
	if not gameplay.is_ready:
		return
	if is_destroying:
		return
	if position.x>get_viewport_rect().size.x+_radius:
		#prints("disappear>>",position,_radius,get_viewport_rect())
		destroy()
	# 在泡泡链中，不移动
	if is_in_drag_mode():
		return
	position = step_wave_move(delta)
	#position = new_pos.clamp(safe_dist, get_viewport_rect().size-safe_dist)

#region life-cycle
func _enter_tree():
	if not visible:
		return
	BubbleCtrl.add_bubble(self)
	#prints(get_path(),"_enter_tree")
func _exit_tree():
	if not visible:
		return
	BubbleCtrl.remove_bubble(self)
	#prints(get_path(),"_exit_tree")
#endregion

#region input
func _on_area_2d_mouse_entered():
	is_mouse_in_shape = true
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		enter_drag_mode()
func _on_area_2d_mouse_exited():
	is_mouse_in_shape = false
func _on_area_2d_input_event(viewport, event, shape_idx):
	if is_mouse_in_shape:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			enter_drag_mode()

func _on_area_2d_area_entered(area):
	if bubble_type != BubbleType.Negtive: # 只有负面泡泡有合并
		return
	
	if not get_viewport_rect().grow(-_radius).grow_side(0,-100).has_point(position):
		return
	#prints("area entered>>area",get_node("Area2D"),area)
	var other = area.owner as Bubble
	if other and not other.is_destroying:
		if other.size <= size and other.size <= 3 and size < max_size: # 比自己小的负面或者正面想法会被吸收
			scale_up(other.size)
			other.disappear()
			#prints("absorb bubble>>node",self,other)
#endregion

#region drag handle
func enter_drag_mode():
	if not gameplay.is_ready:
		return
	if BubbleCtrl.is_chain_done:
		return
	if is_triggered:
		return
	if bubble_type == BubbleType.Positive:
		is_triggered = true
		join_chain();
	else:
		if BubbleCtrl.chain_count >= 3: #至少x个泡泡才能消除
			var delta = max(BubbleCtrl.chain_total_size-3,1)
			#max(BubbleCtrl.chain_count,BubbleCtrl.chain_max_size)-3+1
			scale_down(delta)
		BubbleCtrl.clean_chain_bubble()
		BubbleCtrl.is_chain_done = true # 提前结束了
		
func leave_drag_mode():
	is_triggered = false
func is_in_drag_mode():
	return is_triggered
#endregion

func clear_chain_info():
	leave_drag_mode()
	reset_state()
	if BubbleCtrl.is_chain_done:
		sfx_chain_fail.play()
func join_chain():
	_color = chain_color
	queue_redraw()
	BubbleCtrl.add_chain_bubble(self)
	sfx_join_chain.play()

#region random wave move
var _wave_init_pos:Vector2
var _wave_pos:=Vector2.ZERO
var _wave_x_scale=0.5 #值越大，采样间距越大
var _wave_y_scale=200 #值越大，浮动范围越大

func init_wave_move(init_pos): # x,y 为泡泡的初始位置
	wave_noise.seed = random.randi()
	wave_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	wave_noise.fractal_octaves = 1
	wave_noise.frequency = 1.0 / 100.0 # 后面的20 是晶格的间距，值越大，晶格间距越大
	_wave_init_pos = init_pos
	
func step_wave_move(delta):
	_wave_pos.x += speed*delta
	_wave_pos.y = wave_noise.get_noise_1d(_wave_x_scale*_wave_pos.x)*_wave_y_scale
	return _wave_init_pos + _wave_pos
#endregion 

#region scaling & destroy
func scale_up(delta_size):
	delta_size = 1 # 直接加1点，降低难度
	var tmp = size
	size = min(max_size,size+delta_size)
	speed = speed * tmp / size
	reset_state()
	get_tree().call_group("score","sub_score")
	sfx_scale_up.play()
	if size >= max_size:
		boom()
		get_tree().call_group("score","sub_hp")
	
func scale_down(delta_size):
	var tmp = size
	size = max(0,size-delta_size)
	sfx_scale_down.play()
	if size <= 0:
		disappear()
		get_tree().call_group("score","add_score",2)
	else:
		speed = speed * tmp / size
		reset_state()
		get_tree().call_group("score","add_score")
	
func boom():
	is_destroying = true
	animation_tree["parameters/conditions/is_boom"]=true
	animation_tree["parameters/conditions/is_disappear"]=false
	sfx_boom.play()
	#destroy()
func disappear():
	is_destroying = true
	animation_tree["parameters/conditions/is_boom"]=false
	animation_tree["parameters/conditions/is_disappear"]=true
	if bubble_type == BubbleType.Positive:
		sfx_disappear_y.play()
	else:
		sfx_disappear_b.play()
	#prints("disappear>>tree",animation_tree["parameters/conditions/is_disappear"])
	#destroy()
func _on_animation_tree_animation_finished(anim_name):
	destroy() # 利用了bubble动画树的特点，只要有结束回调，就一定是消失的动画
	pass
#endregion

#region
#endregion
